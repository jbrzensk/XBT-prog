! compile using:
! Make -f gvdel98.mk
!
! RECHECK your bathymetry for each section - you must use the same
!  bathy otherwise your volume will be wrong.
!
!5mar2020 add p40 pieces (lon,gri*d*, lev0=81), stop writing 3 testdel*
!
!09may2014 LL add checks for p38, must recheck someday.
! 13may2013 LL debug my xbtdep - previously I just used the leftmost xbt
!  e file depth to figure out where to interpolated across, double check
!  BOTH surrounding XBT's of grid point and use shallower one.
!  PLUS_ try to create a "mask" of the bottom. This should be fun. I'm
!   going to to try using the combo e hb's and SnS to create the mask.
!   Note that is different than the e file depths that I'm using to do
!   the del interpolation between "shallow" xbt's.

!22may2012 LL - p05 values near equator too large to put in my normal 
! .vel format, so anything less than -9999, set to -9999.99
! 21may2012 LL clean up so consistent - ie using grid point positions
!   for calculation (vs end points to get dltdln)
! 16may2012 LL - Bottom topography mods - read in del grid as before,
!   BUT, read latlonbathgrid.txt to find shallowest depth of XBT that
!   Neighbors each del grid point. Not sure this is perfect since we use
!   objective mapping to create the del grid, and I'm using more than
!   just the 2 neighbor XBT's to create the each del grid data column,
!   but it's probably close enough. So for each del column, set the del
!   value to 999.0 if it's below the shallowest XBT Neighbor depth.
!   Then for each edge (left and right) fill those 999.0 values in from
!   the next drop that contains real data. Once the edges are filled in
!   go through the rest of the del grid columns and linearly interpolate
!   any missing values.
!   Also, make sure idim=81 !!
!   So now only ONE way to run this since bathymetry is set - run 
!   with lev0=81 and let's call the output *.vxl for xbt depth defined
!   velocity. :)
!
!---------------------------------------------------------------
!           
! 8may2012 LL try to add .ssa/.ssc and .dsa/.dsc (Argo TS)
!   + mods for p37 (44/10/37) to read position from trkpos.txt
!
!   ALSO - mapxbt3 creates trkpos.txt - which is lat,lon for each
!   grid pt - so use that in ALL cruises instead of endpts. (I hope)
!
! 01feb2011 LL write out dynamic height for Nathalie dynht(nymx,nxmx)
! 28sep2010 make lev0=81 default
! 04aug2010 - USE lev0=81 for ALL, leaving =86 for now until rerun 
! each line.  Also note escale is NOT used anymore!   the vel/vec/vtc grid
! is written before vsmth is called.   That was used back in MYM days.
!03aug2010 - Nathalie Z wnats gvdel for p05 for whole track. (xmax)
! (per Dean, velocity is calculated normal to the track)
! (per Dean, Velocity in cm/sec)
!
!23jul2010 - for p05, let's read in matching xlat,xlon for each grid 
! pt and calc dist from those (instead of transect end points only)
!22jul2010 - doing p05 - per Dean, stop at 3 south so equator calcs don't
! overflow. - change gvel bounds to -3 to +3
! 28may2009 LL segment fault with p380905?
!7may2009 LL changes
! 4-13-98-LL combine gvdel.f and gvdelp37.f into one program.  Go over with
! John/Dean to be sure correct version for p37.  Modify for p81 - since this
! does not work near the equator: if in latitude range 5 S to 5 N put a
! -999.99 as a missing data value.  Also check with John/Dean about rm'ing
! hsmth (vsmth?)for p37 runs, since I have note to not call it, yet we're
! calling it.   Set up so operator can modify lev0, escale

! 1-24-95 take out call to hsmth for p37 runs!
!
! calculate geostrophic velocity from del grid
! CHECK escale!  =50 for p37, =10 for rest.
!
        parameter( nxmx=1500, nymx=90, nt=4)
        dimension xglon(nxmx), xglat(nxmx), xbtdep(nxmx)
        dimension xbt_sns_dep(nxmx)
        integer igdim(nxmx)
        integer ig_est_bot_dim(nxmx)
        dimension dynht(nymx,nxmx)
        dimension sva(nymx,nxmx),dht1(nymx),dht2(nymx),v(nymx)
        dimension xlat(nxmx),xpdr(500),zpdr(500),vr(nxmx),vrs(nxmx)
        dimension xtmp(500),ztmp(500)
        dimension t(nxmx),s(nxmx),d(nymx),vrs2(nxmx),tpud(nymx)
        dimension dis1(nxmx),xlon(nxmx)
        dimension iport(9)
        character f1*12,f2*12,f3*12,f4*14,stafl*11,f6*9,f5*9
        character f8*12
        character line*81
        character latlon*3, ans*1, xbtinfo*12, cruise*8
        character p09xbtinfo*21
        character log*12
        character latlonbathgrid*18
        character latlonbathvgrd*18
        character*1 abotuse, yesorno
        data f1/'p359104a.del'/
        data f3/'p319105a.vel'/
        data f4/'../bathbs.dat'/,b/0./
        data f5/'bath1.dat'/
        data f6/'tpuda.dat'/,dxk/111.1/,dx/.1/,wrtsal/0/,idim/81/
        data f8/'p059104a.dht'/
        data latlonbathgrid/'latlonbathgrid.txt'/
        data latlonbathvgrd/'latlonbathvgrd.txt'/
!                            123456789012345678
        data stafl/'p359104.dat'/
        data xbtinfo/'xbtinfo.p37 '/
        data p09xbtinfo/'/data/xbt/xbtinfo.p09'/
        data degrad/1.745329e-2/
        data log/'gvdellog.vel'/

        write(*,*) ' Enter cruise name: (8 chars) (ie, p379209d) '
        read(5,'(a8)') f1(1:8)
        cruise(1:8) = f1(1:8)
        xbtinfo(9:11) = f1(1:3)
        if(f1(1:3).eq.'p06'.or.f1(1:3).eq.'p09'.or.
     $     f1(1:3).eq.'p50'.or.f1(1:3).eq.'p15'.or.
     $     f1(1:3).eq.'p34'.or.f1(1:3).eq.'p21'.or.
     $     f1(1:3).eq.'s37'.or.f1(1:3).eq.'p31'.or.
     $     f1(1:3).eq.'p05'.or.f1(1:3).eq.'p38'.or.
     $     f1(1:3).eq.'p37'.or.
     $     f1(1:1).eq.'a'.or.f1(1:3).eq.'p44'.or.
     $     f1(2:3).eq.'15'.or.f1(2:3).eq.'21'.or.
     $     f1(1:3).eq.'p13'.or.f1(2:3).eq.'40') then
           latlonbathgrid(14:14) = f1(8:8)
           latlonbathvgrd(14:14) = f1(8:8)
        endif

        its = 1
        write(*,*) ' Use what salinity?  '
        write(*,*) ' 1) Use regular .del file (historical TS)     '
        write(*,*) ' 2) Use Argo corrected historical TS .dec file '
        write(*,*) ' 3) Use p28 ds .ded file :)      '
        write(*,*) ' 4) Use Argo only TS .dsa file      '
        write(*,*) ' 5) Use Argo +argo/xctd corrected .dsc file      '
        write(*,*) ' 0) quit      '
        write(*,*) ' Enter number:  '
        read(5,*) its
        if(its.eq.0.or.its.gt.5) stop 'enter its'

        ibotuse = 1
!        write(*,*)'17may2012 LL moot now, just use 2'
        write(*,*)
        write(*,*)'Use which bottom bathymetry?:'
        write(*,*)' 0 = use the old bathXX.dat:'
        write(*,*)
     $' 1 = Combo of XBT depth and lev0=800m in *deep defined range*',
     $     '(I have only got this working for p31 (01nov2010 LL)',
     $     '(added p05 3jan2011), (try p37 8may2012)'
        write(*,*)'>2 = No bathymetry, set lev0 = 800m '
!        write(*,*)'3 = p05 - use the local bath created from SnS? ',
!     $     '(this is essentially #1, but p05 uses SnS, add XBT later'
        write(*,*)'Enter number (we always use #2 now, lev0 = 800m):'
!
        read(5,'(i1)') ibotuse
        if(ibotuse.lt.0.or.ibotuse.ge.3) stop 'enter 0, 1, or2'

! is it lat or lon based cruise?
        if(f1(1:3).eq.'p05'.or.f1(1:3).eq.'p06'.or.
     $     f1(1:3).eq.'p09'.or.f1(1:3).eq.'p38'.or.
     $     f1(1:3).eq.'a08'.or.f1(1:3).eq.'a10'.or.
     $     f1(1:3).eq.'p13') then
           latlon='lat'
        elseif(f1(1:3).eq.'p31'.or.f1(1:3).eq.'p34'.or.
     $         f1(1:3).eq.'p37'.or.f1(1:3).eq.'s37'.or.
     $         f1(2:3).eq.'15'.or.f1(2:3).eq.'21'.or.
     $         f1(1:3).eq.'a07'.or.f1(1:3).eq.'a18'.or.
     $         f1(1:3).eq.'a97'.or.f1(1:3).eq.'p44'.or.
     $         f1(1:3).eq.'p50'.or.f1(1:3).eq.'p21'.or.
     $         f1(1:3).eq.'p40') then
           latlon='lon'
        else
           stop 'lisa program this latlon in!'
        endif

! output file:
! ok, changed all these YET again 21may2012:
! vxl - historical TS only, use bottom of xbt to determine "bottom" of
!       del grid, then fill/interpolate del grid below bottom. Not using
!       bottom data for anything else.
! vxx - same as vxl, except read in bath1.dat (cruise bottom data) and
!       use that as the bottom. May not need this?
! OLD:
! vel - no argo correction, cruise bathymetry (the old ../bathXX.dat)
! vxl - no argo correction, bottom defined by XBT depth (see above #1)
! vtl - no argo correction, lev0=800m
! vec - argo correction, cruise bathymetry (the old ../bathXX.dat)
! vxc - argo correction, bottom defined by XBT depth (see above #1,#3)
! vtc - argo correction, lev0=800m
! vrg - RG Argo T-S only, bath?
! vxg - RG Argo T-S only, bottom defined by XBT (bath1.dat)
! vtg - RG Argo T-S only, lev0 = 800,
        if(its.eq.1) then      ! no argo correction: use del:
         if(ibotuse.eq.0)  then
                           f3(10:12) = 'vel'
                           log(10:12) = 'vel'
         elseif(ibotuse.eq.1)  then
                           f3(10:12) = 'vxx'
                           log(10:12) = 'vxx'
         elseif(ibotuse.eq.2)  then
! used to be vtl (17may2012)
                           f3(10:12) = 'vxl'
                           log(10:12) = 'vxl'
         elseif(ibotuse.eq.3)  then
                           f3(10:12) = 'vxl'
                           log(10:12) = 'vxl'
         endif
        elseif(its.eq.2) then      ! argo correction:
         f1(12:12) = 'c'
         if(ibotuse.eq.0)  then
                           f3(10:12) = 'vec'
                           log(10:12) = 'vec'
         elseif(ibotuse.eq.1)  then
                           f3(10:12) = 'vxc'
                           log(10:12) = 'vxc'
         elseif(ibotuse.eq.2)  then
! used to be vtc
                           f3(10:12) = 'vxc'
                           log(10:12) = 'vxc'
         elseif(ibotuse.eq.3)  then
                           f3(10:12) = 'vxc'
                           log(10:12) = 'vxc'
         endif
        elseif(its.eq.3) then      ! ds 
         f1(12:12) = 'd'
         if(ibotuse.eq.0)  then
                           f3(10:12) = 'ved'
                           log(10:12) = 'ved'
         elseif(ibotuse.eq.1)  then
                           f3(10:12) = 'vxd'
                           log(10:12) = 'vxd'
         elseif(ibotuse.eq.2)  then
! used to be vtl
                           f3(10:12) = 'vxd'
                           log(10:12) = 'vxd'
         elseif(ibotuse.eq.3)  then
                           f3(10:12) = 'vxd'
                           log(10:12) = 'vxd'
         endif
        elseif(its.eq.4) then      ! Argo only TS (.10s_argo)
         f1(10:12) = 'dsa'
         if(ibotuse.eq.0)  then
                           f3(10:12) = 'vsa'
                           log(10:12) = 'vsa'
         elseif(ibotuse.eq.1)  then
                           f3(10:12) = 'vsa'
                           log(10:12) = 'vsa'
         elseif(ibotuse.eq.2)  then
                           f3(10:12) = 'vsa'
                           log(10:12) = 'vsa'
         elseif(ibotuse.eq.3)  then
                           f3(10:12) = 'vsa'
                           log(10:12) = 'vsa'
         endif
        elseif(its.eq.5) then      ! Argo + XCTDargo corr TS (.10c_argo)
         f1(10:12) = 'dsc'
         if(ibotuse.eq.0)  then
                           f3(10:12) = 'vsc'
                           log(10:12) = 'vsc'
         elseif(ibotuse.eq.1)  then
                           f3(10:12) = 'vsc'
                           log(10:12) = 'vsc'
         elseif(ibotuse.eq.2)  then
                           f3(10:12) = 'vsc'
                           log(10:12) = 'vsc'
         elseif(ibotuse.eq.3)  then
                           f3(10:12) = 'vsc'
                           log(10:12) = 'vsc'
         endif
        endif
!
        open(33,file=log,status='unknown',form='formatted')
! make tpuda.XXX match above...
        f6(7:9) = f3(10:12)

        write(33,*)'Cruise name=', f1(1:12)

        write(33,*) f1(1:3), ' latlon=', latlon
        write(33,*) 'open latlonbathgridfile=',latlonbathgrid
! 16may2012 LL open local latlonbathgrid.txt to get shallowest XBT depth
!  of the TWO surrounding XBT's to this grid point: (is that correct?)
! recall latlonbathgrid.txt is already ordered same as del grid
! 18apr2013 - note you are just reading 1 of the elo/ehi values and sometimes
!             elo > ehi - this could screw you, so check it.
! 10may2013 LL ok, read in all 3 'depth' values from latlonbathgrid.txt:
! glat, glon, depth-interpd-to-glat-glon-from depth-combo-e-sns, depth-e-left-xbt,depth-e-right-xbt
! latlonbathgrid.txt created in mkgridbath.f
! dep_e_sns = depth-interpd-to-glat-glon-from depth-combo-e-sns : is my estimate of the actual
!       bottom depth using SnS & e-HB's 
! dep_e_left = depth-e-left-xbt : is the depth of the XBT to left of grid point
! dep_e_right = depth-e-right-xbt : is the depth of the XBT to right of grid point
!    Recall the depth-e-*-xbt is just that, bottom of XBT drop - could be anything:
!            wire break, hb, etc
        open(50,file=latlonbathgrid,status='old',
     $          form='formatted',err=50)
        go to 3
50      stop 'missing latlonbathgrid.txt, run mkgridbath.x'
3       continue
        do 5 i = 1, nxmx
4          read(50,554,end=6,err=6) 
     $          xgla,xglo,dep_e_sns,dep_e_left,dep_e_right
554        format(2f9.3,3f7.0)
! If 999.0 then no data here, skip:
           if(dep_e_sns.eq.999.0) go to 4
! 10may2013 find shallower depth of xbt dep_e_left or dep_e_right
           xglat(i) = xgla
           xglon(i) = xglo
! xbt_sns_dep(i) is the estimated depth at this grid pt from e & sns & 0.0=island
!           xbt_sns_dep(i) = dep_e_sns
! xbtdep(i) is the depth of the shallower xbt e file that surrounds this grid point:
           xbtdep(i) = dep_e_left
! (what to do with dep_e_* = 0.0 (island?)...ok, I'm going to keep my "added" 
!  depth=0.0 at 166.75 for p31 (when cruise visits noumea) so that we'll interpolate
!  all the way across between the 2 surrounding XBT's
!
! using .gt. cuz we are comparing negative numbers:
           if(dep_e_right.gt.dep_e_left) xbtdep(i) = dep_e_right
5       continue
6       continue
        ndep = i-1
        write(33,*)'ndep=',ndep,'i,xglon,xglat,xbtdep,igdim'
! igdim(i)= find index of "xbtdep(i)" - recall that's the shallowest xbt depth
!   surround this (i) gridpoint.
! Let's add another igdim - call it ig_est_bot_dim(i) to really confuse me.
!  This will be the index of my estimated bottom depth (using e hb's and sns)
        do 7 i = 1, ndep
           igdim(i) = abs(int(-xbtdep(i)/10.0))+1
           write(33,*) i, xglon(i), xglat(i), xbtdep(i), igdim(i)
7       continue  
        close(50)
! ok, recall that you created an estimated depth for the middie vel grid points, so
! use that to created your "mask" for Nathalie:
        write(33,*)'open ', latlonbathvgrd
        open(51,file=latlonbathvgrd,status='old',
     $          form='formatted',err=50)
        do 75 i = 1, nxmx
74          read(51,574,end=76,err=76)
     $          xgla,xglo,dep_e_sns
574        format(2f9.3,f7.0)
! If 999.0 then no data here, skip:
           if(dep_e_sns.eq.999.0) go to 74
! xbt_sns_dep(i) is the estimated depth at this grid pt from e & sns & 0.0=island
           xbt_sns_dep(i) = dep_e_sns
75       continue
76       continue
        ndepv = i-1
        write(33,*) 'ndep,ndepv', ndep, ndepv
        do 177 i = 1, ndepv
           ig_est_bot_dim(i) = abs(int(-xbt_sns_dep(i)/10.0))+1
177          write(33,*) i, xglon(i), xglat(i), xbt_sns_dep(i), 
     $                 ig_est_bot_dim(i)
        close(51)

! normal, xmax = 90, recall xmax is latitude maximum
        xmax = 90.0
! to run with p09 lt 18 S
        if(f1(1:3).eq.'p09') then
          xmax = -4.95 ! 21may2012 LL for p09 17 South to 5 South
! OLD OLD OLD:          xmax = -18.15
!        elseif(f1(1:3).eq.'p05') then
!          write(*,*)'For PX05, stop at 2.9 south? y or n'
!          read(5,'(a1)') yesorno
!          if(yesorno.eq.'y') xmax = -2.90
        endif
!
        write(33,*) '(maximum latitude) xmax=',xmax
        write(*,*) '(maximum latitude) xmax=',xmax
!
!recall f4 is OLD .../bathXX.dat file
        if(cruise(1:3).eq.'p08'.and.ibotuse.eq.0) then
           call rdxbtinfo2(xbtinfo,cruise,iport)
           f4(8:9) = 'dp'
           if(iport(3).eq.1) f4(8:9) = 'ap'
           write(*,*)'using ', f4(8:9)
           write(33,*)'using ', f4(8:9)
        elseif(cruise(1:3).eq.'p08'.and.ibotuse.eq.1) then
           stop 'program this in'
        elseif(cruise(1:3).eq.'p08'.and.ibotuse.eq.2) then
           stop 'program this in'
! 28mar2011 LL add p09 bathXX from xbtinfo (NOT PERFECT)
        elseif((cruise(1:3).eq.'p09'.or.cruise(1:3).eq.'p13').and.
     $           ibotuse.eq.0) then
          open(22,file=p09xbtinfo,status='old',form='formatted',err=578)
          do ii = 1, 200
           read(22,'(a81)',err=578) line
           if(line(1:5).eq.cruise(4:8)) then
            f4(8:9) = line(80:81)
            go to 66
           endif
          enddo
66        continue
          close(22)
          write(*,*)'using ', f4(8:9)
          write(33,*)'using ', f4(8:9)
        elseif((cruise(1:3).eq.'p09'.or.cruise(1:3).eq.'p13')
     $          .and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
            f5(5:5) = cruise(8:8)
        elseif((cruise(1:3).eq.'p09'.or.cruise(1:3).eq.'p13')
     $          .and.ibotuse.eq.2) then
           lev0 = 81
! for p31 - if using old style bathXX.dat file, get XX from xbtinfo.p31:
        elseif(cruise(1:3).eq.'p31'.and.ibotuse.eq.0) then
          open(22,file='/data/xbt/xbtinfo.p31',status='old',
     $            form='formatted',err=578)
          do ii = 1, 200
           read(22,'(a81)',err=679) line
           if(line(1:4).eq.cruise(4:7)) then
            f4(9:9) = line(30:30)
            go to 67
           endif
          enddo
679       stop 'error reading xbtinfo.p09'
67        continue
          close(22)
          write(*,*)'using ', f4(8:9)
          write(33,*)'using ', f4(8:9)
        elseif(cruise(1:3).eq.'p31'.and.ibotuse.eq.1) then
! ibotuse=1, use file "edeps" in each cruise directory.Must run find-e-dep.x first!
! 24nov2010 updated: use bath1.dat - combo of edeps-old and mkcruisebath.f
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p31'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'s37'.and.ibotuse.eq.0) then
           f4(8:9) = 's1'
        elseif(cruise(1:3).eq.'s37'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'s37'.and.ibotuse.eq.2) then
           lev0 = 81
!-------------------------------------------------------------------------
!        elseif(cruise(1:3).eq.'p37'.and.cruise(8:8).eq.'a') then
!           call rdxbtinfo2(xbtinfo,cruise,iport)
!           f4(8:9) = 'ko'
!           if(iport(5).eq.1) f4(8:9) = 'hk'
!           write(*,*)'using ', f4(8:9)
!           write(33,*)'using ', f4(8:9)
!-------------------------------------------------------------------------
        elseif(cruise(1:3).eq.'p37'.and.ibotuse.eq.0) then
           write(*,*) ' Enter 2 character bathymetry file id (ie, ko)'
           read(5,'(a2)') f4(8:9)
        elseif(cruise(1:3).eq.'p37'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p37'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'p05'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p05'.and.ibotuse.eq.2) then
           lev0 = 81
!09may2014 p38 added, recheck your work here...
        elseif(cruise(1:3).eq.'p38'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p38'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'p34'.and.ibotuse.eq.0) then
           f4(8:9) = 'sw'
        elseif(cruise(1:3).eq.'p34'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p34'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'p06'.and.ibotuse.eq.0) then
           stop ' add p06 bathXX.dat reading here'
        elseif(cruise(1:3).eq.'p06'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
            f5(5:5) = cruise(8:8)
        elseif(cruise(1:3).eq.'p06'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'p50'.and.ibotuse.eq.0) then
           stop ' add p50 bathXX.dat reading here'
        elseif(cruise(1:3).eq.'p50'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(1:3).eq.'p50'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(2:3).eq.'15'.and.ibotuse.eq.0) then
           stop ' add p15 bathXX.dat reading here'
        elseif(cruise(2:3).eq.'15'.and.ibotuse.eq.1) then
            f5 = 'batha.dat'
        elseif(cruise(2:3).eq.'15'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:3).eq.'i15'.and.ibotuse.eq.0) then
           stop ' add p15 bathXX.dat reading here'
        elseif(cruise(1:3).eq.'i15'.and.ibotuse.eq.1) then
            f5 = 'batha.dat'
        elseif(cruise(1:3).eq.'i15'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(2:3).eq.'21'.and.ibotuse.eq.0) then
           stop ' add p15 bathXX.dat reading here'
        elseif(cruise(2:3).eq.'21'.and.ibotuse.eq.1) then
            f5 = 'batha.dat'
        elseif(cruise(2:3).eq.'21'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(1:1).eq.'a'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(2:3).eq.'44'.and.ibotuse.eq.1) then
            f5 = 'bath1.dat'
        elseif(cruise(2:3).eq.'44'.and.ibotuse.eq.2) then
           lev0 = 81
        elseif(cruise(2:3).eq.'40'.and.ibotuse.eq.2) then
           lev0 = 81
        else
           stop 'lisa you do not have this option coded'
        endif
! lev0
        lev0 = 81
        if(f1(1:3).eq.'p50'.or.f1(1:3).eq.'p37'.or.
     $     f1(1:3).eq.'p05'.or.f1(1:3).eq.'s37') lev0 = 81

!        write(*,*)'Normally lev0=86 (850m) for most cruises'
!        write(*,*)'   "     lev0=81 (800m) for p50, p37'
        write(*,*)
        write(*,*)'Currently lev0=', lev0
        write(*,*)'Only enter "n" next if you want to customize lev0:'
        write(*,*)'Type [y] to keep, or n to change lev0:'
        read(5,'(a1)') ans
        if(ans(1:1).eq.'n') then
         write(*,*) 'enter new lev0='
         read(5,*) lev0
        endif
        write(*,*) 'lev0=',lev0
        write(33,*) 'lev0=',lev0

        stafl(1:7)=f1(1:7)
        f2(1:8)=f1(1:8)
        f3(1:8)=f1(1:8)
        f8(1:8)=f1(1:8)
!        if(f1(1:3).eq.'p05'.and.yesorno.eq.'n') f3(8:8) = 'b'
        f6(5:5) = f1(8:8)
! 9may2012 shouldn't this be just 0
        if(ibotuse.eq.0.or.ibotuse.eq.3) then
           write(33,*)' open f4= ',f4
           write(*,*)' open f4= ',f4
           open(unit=12,file=f4,status='old')
! 9may2012 and this be 1 and 3 ?
        elseif(ibotuse.eq.1) then
           write(33,*)' open  ',f5
           open(unit=12,file=f5,status='old')
!        elseif(ibotuse.eq.2) then
!           write(33,*)' open  ',f4
!           open(unit=12,file=f4,status='old')
        endif
        write(33,*)' open  ',f1
        open(unit=7,file=f1,status='old')
        write(33,*)' open  ',f3
        open(17,file=f3,status='unknown')
        open(15,file=f6,status='unknown')
        write(33,*)' open ',stafl
        open(14,file=stafl)
        open(18,file=f8,status='unknown',form='formatted')

! read del file header:
! nc= number columns in del file
! nr= number rows in del file
! xl= left lat/lon, xr= right lat/lon
! yb= bottom depth, yt = top depth
        read(7,*)nc,nr,xl,xr,yb,yt
        if(yb.gt.0.)yb=-1.*yb
        dy=(yt-yb)/float(nr-1)
        dx=(xr-xl)/float(nc-1)
!        write(*,*) 'nc=',nc,' nr=',nr,' xl=',xl,' xr=',xr,' dx=',dx
        write(33,*) 'nc=',nc,' nr=',nr,' xl=',xl,' xr=',xr,' dx=',dx
        nc2 = nc
! 10jun2011 set nr=81 for p28 !
        if(f1(1:3).eq.'p28') then
           nr = 81
           print *, 'LISA YOU SET nr=81 for p28!'
        endif
     
! continue reading del file:
        do 10 i=1,nr
          read(7,'(11f7.2)')(sva(i,j),j=1,nc)
!do later          do 15 j=1,nc
!do later           sva(i,j)=1.e-5*sva(i,j)
!do later15        continue
! setting d(i) = depth, so d(1) = 0.0, d(2) = 10.0, ... d(86)=850.
          d(i)=dy*float(i-1)
!          write(33,*)'d(i)=',d(i),' i=',i
10      continue
! 16may2012 LL ok a bit convoluted, but it should work, we know the last
!  good depth of each grid point (see above, xglat, xglon, xbtdep, igdim)
!  so go through sva col by col j=1,nc, look at igdim - that's the
!  dimension of the depth of the real data, and anything below that in
! each column, set to 999.0
        do 39 j = 1, nc
           do 38 i = 1, nr
! this igdim is matched to tem/sal/del grid points:(13may2012 changed gt to ge):
              if(i.ge.igdim(j)) sva(i,j) = 999.0
38         continue
39      continue

! better write it out to check....
!        open(77, file='testdel1',status='unknown',form='formatted')
!        do 215 i=1,nr
!           write(77,'(20f7.2)')(sva(i,j),j=1,nc)
!215     continue
!        close(77)
! Have to fill in from col 1 to col X, where X goes to 800m
!            and col nc to col nc-X, where nc-X goes to 800m. :)
!   sva(row,col)
! HoW TO HANDLE ISLANDS?
! j800 = 1 means grid pt has data to 800m, set to 0 if missing data so
!        keep looking for first deep drop
        do 668 j = 1, nc
         j800 = 1
         do 68 i = 1, nr
           if(sva(i,j).eq.999.0) then
              if(i.le.81) j800 = 0
              do 266 k = j+1, nc
                 if(sva(i,k).ne.999.0) then
                    sva(i,j)=sva(i,k)
                    go to 68
                 endif
266            continue
               write(33,*)'no value,i, sva',i,sva(i,1)
           endif !(sva(i,j).eq.999.0
68       continue
! j800=1 means the last column checked had real data to 800m
         if(j800.eq.1) go to 669
668      continue
669      continue
! last cols:
        do 768 j = nc, 1, -1 
        j800 = 1
        do 168 i = 1, nr
           if(sva(i,j).eq.999.0) then
              if(i.le.81) j800 = 0
              do 166 k = j-1, 1, -1
                 if(sva(i,k).ne.999.0) then
                    sva(i,j)=sva(i,k)
                    go to 168
                 endif
166            continue
           write(33,*)'no value,i, sva',i,sva(i,nc)
           endif
168      continue
! j800=1 means the last column checked had real data to 800m
         if(j800.eq.1) go to 769
768      continue
769      continue
! better write it out to check....
!        open(77, file='testdel2',status='unknown',form='formatted')
!        do 315 i=1,nr
!           write(77,'(20f7.2)')(sva(i,j),j=1,nc)
!315     continue
!        close(77)
! now try to do interpolation for cols 2 to nc-1, won't work for
! carrying deep value in toward islands though...
! actually will have to look further away than neighbor columns to
! get data, so will need to linearly interpolate taking into account
! distance.
         do 268 j = 2, nc-1
            do 267 i = 1, nr
               if(sva(i,j).eq.999.0) then
!                 if previous point is 999.0 then set to 999.0:
                  if(sva(i,j-1).eq.999.0) then
                     sva(i,j) = 999.0
                  elseif(sva(i,j+1).ne.999.0) then
                     sva(i,j) = (sva(i,j-1) + sva(i,j+1))/2.0
                  elseif(sva(i,j+1).eq.999.0) then
!                 need to find next non 999.0 point:
                     do 367 k = j+2, nc
                        if(sva(i,k).ne.999.0) then
                           frac=real(j-(j-1))/real(k-(j-1))
                           sva(i,j)= 
     $                           sva(i,j-1)+(sva(i,k)-sva(i,j-1))*frac
!       write(33,*)'frac=',frac,sva(i,j-1),sva(i,k), sva(i,j)
                           go to 267
                        endif
367                  continue
! no point past ne 999.0 so set it to 999.0
                     sva(i,j) = 999.0
                  endif
               endif
267         continue
268      continue 
! better write it out to check....
!        open(77, file='testdel',status='unknown',form='formatted')
!        do 115 i=1,nr
!           write(77,'(20f7.2)')(sva(i,j),j=1,nc)
!115     continue
!        close(77)
! now do this:
         do 15 i = 1, nr
         do 15 j=1,nc
           sva(i,j)=1.e-5*sva(i,j)
15        continue

!21may2012 LL ALL must use trkpos.txt now. :)
!24may2012 LL switch to latlonbathgri{a,b,c}.txt!
          write(33,*) 'open latlonbathgridfile=',latlonbathgrid
          open(50,file=latlonbathgrid,status='old',form='formatted',
     $            err=16)
! this do 55 loop is reading in the gridded track position written,
! by mapxbt3. Looks like I'm sorting W-E or S-N, however I
! did that in mapxbt3. Just leave it in case I screwed up somewhere else.
          ifoundfirst = 0
          j = 1
          do 55 i = 1, nxmx
             read(50,555,end=56,err=56) xlt, xln
!             write(33,*) xlt,xln,ifoundfirst
             if(latlon.eq.'lat') then
              xcomp = xlt
             elseif(latlon.eq.'lon') then
              xcomp = xln
             endif
             if(ifoundfirst.eq.0.and.xl.ne.xcomp) then
!                write(33,*) 'going to 55, xl=',xl,' xcomp=',xcomp
                go to 55
             else
                xlat(j) = xlt
                xlon(j) = xln
                ifoundfirst = 1
                j = j + 1
!                write(33,*) xlt,xln,ifoundfirst,j
             endif
555          format(2f9.3)
!             write(33,*)'xlat(j)=',xlat(j-1),'xmax=',xmax
!             if(ifoundfirst.eq.1.and.xlat(j-1).gt.xmax)then
!                nc2=j-2
!                xr=xlat(j-2)
!                go to 111
!             endif
55        continue
56        continue
          close(50)
111       nc=nc2
          write(33,*) 'finish reading/sorting latlonbathgrid.txt input'
          do 77 i = 1, nc
             write(33,*)'xlat,xlon ', i,xlat(i),xlon(i)
77        continue
!
! this is the old ../bathXX.dat file:
        if(ibotuse.eq.0) then
         read(12,*)npdr    
         read(12,*)        
! change to -3 since last number in bath**.dat file is first # - LL
!        npdr=npdr-2       
         npdr=npdr-3       
         write(33,*)'npdr=',npdr
         do 1015 i=1,npdr  
          read(12,*)xpdr(i),zpdr(i)
          write(33,*) 'xpdr,zpdr', xpdr(i), zpdr(i), i
          write(*,*) 'xpdr,zpdr', xpdr(i), zpdr(i), i
          call flush(33)
1015      zpdr(i)=-zpdr(i)  
! Use local bath1.dat file (combo of edeps and SnS)
        elseif(ibotuse.eq.1) then
! recall need to read lon for p31
! skip first line of header info:
         read(12,*)        
! my edeps varies E-W, W-E, gvdel wants W-E:
         do 910 i=1,1000  
          read(12,'(f8.3,9x,f7.0)',end=911,err=911)xtmp(i),ztmp(i)
910       ztmp(i)=-ztmp(i)  
911       npdr=i-1
! order baths correctly:
          if(xtmp(1).lt.xtmp(2)) then
             do 569 i = 1, npdr
                xpdr(i) = xtmp(i)
                zpdr(i) = ztmp(i)
569          continue
          else
             kk = 1
             write(33,*)'swapum'
             do 568 i = npdr, 1, -1
                xpdr(kk) = xtmp(i)
                zpdr(kk) = ztmp(i)
                kk = kk + 1
568          continue
          endif
          write(33,*)'npdr=',npdr
          do 570 i = 1, npdr
             write(33,*) 'xpdr,zpdr', xpdr(i), zpdr(i), i
570       continue
        endif
!
! compute geostrophic velocity
        do 90 j=1,nc
! TO DO - for p05 this xln should probably = xlon(j) ?  CHECK 8oct2010 LL
! ah, xla2 only used for xgm which is currently NOT used for p31,p37,p05,
! but it's probably wrong for p09?! check - once start using trkpos.txt
! for p09 should be ok
! xl= left grid point from del grid
! so calc xln as 0.5 past del/tem/sal grid point:
          xln=xl+float(j-1)*dx+0.5*dx
          xla2=xlat(j)

!          write(33,*) 'xln,xla2=',xln,xla2 
            
          call dyndp(d,sva(1,j),dht2,nr)
! 01feb2011 LL put dht2 into dynht 2 dim array for Nathalie, note here dht2 matches tem/sal, not vel
          do i = 1, nr
           dynht(i,j) = dht2(i)
          enddo
! skip to 200 if first grid point (j=1) (where I set xla1=xla2)
          if(j.eq.1)go to 200        
! xgm appears to NOT be used (may2013)
          xgm=0.5*(xla2+xla1)
! bottom check:         
! 9may2012 LL screwed! this is (will be was!) using the depth of the NEXT
! middie grid pt!, so subtract .1 to get the current middie point:
! TEST:---------------------------
!   this only matters for ibotuse=1 or 0, not for my current mode (may2013)
          xln = xln -0.1
! END TEST----------------------
! lev0 is set to 81
          if(ibotuse.eq.1.or.ibotuse.eq.0) then
             write(33,*)'call dimv xln=',xln,
     $     ' dy=',dy,' npdr=',npdr,' idim=',idim
!     $       ' zpdr,xpdr=',(zpdr(kk),xpdr(kk),',',kk=1,npdr),
!
             call dimv(xln,zpdr,xpdr,dy,npdr,idim)        
!
             write(33,*)'past dimv xln=',xln,' idim=',idim
          endif
          idim=min(idim,nr)
          write(33,*)'aft min(idim,nr),set idim= ',idim
!
! will this work for p81 crossing equator?
! ok, I'm not going to touch this because it's working, but how
!  convoluted is it!: (14may2012 LL whoa, not setting isign for first
!  call to gvel - change the if to look at xla2, not xla1 ? (xln no go)
! old:          if(xla1.le.0.0) then

! just add what you know:
          if(f1(1:3).eq.'p34'.or.f1(1:3).eq.'p31') then
             isign = -1
          elseif(f1(1:3).eq.'p37'.or.f1(1:3).eq.'s37') then
             isign = 1
          elseif(xla1.le.0.0) then
! Southern Hemisphere
             isign=-1
             if(latlon.eq.'lat')isign=1
          else
! Northern Hemisphere
             isign=1
             if(latlon.eq.'lat')isign=-1
          endif

! 21may2012 LL calculate distance - recall this used to use dltdln, but
! now that we have lat,lon for EACH grid point, use that for ALL:
! Probably want to double check it.
!           write(*,*)'dxk=',dxk,xlat(j),xlat(j-1),xlon(j),xlon(j-1)
!           write(33,*)'dxk=',dxk,xlat(j),xlat(j-1),xlon(j),xlon(j-1)
!           write(*,*)'cos',cos(degrad*(0.5*(xlat(j)+xlat(j-1))))**2
!           write(33,*)'cos',cos(degrad*(0.5*(xlat(j)+xlat(j-1))))**2 
!           write(*,*) 'lat',(dxk*(xlat(j)-xlat(j-1)))**2
!           write(33,*) 'lat',(dxk*(xlat(j)-xlat(j-1)))**2
!           write(*,*) 'lon',dxk*abs(xlon(j)-xlon(j-1))
!           write(33,*) 'lon',dxk*abs(xlon(j)-xlon(j-1))
!
           dis1(j-1) = sqrt( (dxk*(xlat(j)-xlat(j-1)))**2 +
     $       (dxk*abs(xlon(j)-xlon(j-1))*
     $        cos(degrad*(0.5*(xlat(j)+xlat(j-1)))))**2 )
           xla2 = xlat(j)
           xla1 = xlat(j-1)

!          write(*,567)xla2,xla1,dis1(j-1),isign,idim,lev0,nr 
!          write(33,567)xla2,xla1,dis1(j-1),isign,idim,lev0,nr 
          write(33,*)'xla2,xla1,dis1(j-1),isign,idim,lev0,nr '
          write(33,567)xla2,xla1,dis1(j-1),isign,idim,lev0,nr 
567       format(2f8.3,' dis1=',f6.3,4i4)

          write(33,*)'ah HA! xlatj-1,xlatj,xlonj-1,xlonj'
          write(33,*)xlat(j-1),xlat(j),xlon(j-1),xlon(j)
          write(33,*)'calling gvel:'

! if latitude between 5 S and 5 N set to -999.99 (do in gvel)
! 22jul2010:if latitude between 3 S and 3 N set to -999.99 (do in gvel)
          call gvel(xla2,xla1,dis1(j-1),dht2,dht1,isign,v,idim,
     $              b,lev0,nr) 
!13may2013 LL
! v(nr) is returned from sub gvel. recall you set anything below idim+1 = -999.99
! Nathalie wants a bottom mask. Let's try to:
! 1) set v(lev0) aka v(81) = -999.99 (it's calculated as =0.0)
! 2) set v(ig_est_bot_dim(i)) = -999.99
!  recall we are inside do loop 90 using j = 1, number of columns
!  since we read in latlonbathvgrd - it's already j-1, so need to use
!  j-1 here since do 90 loop does not get here for j=1
          ishallower = min(lev0,ig_est_bot_dim(j-1))        
          write(33,*) 'min of ', lev0,ig_est_bot_dim(j-1),'=',ishallower
          do 220 jj = ishallower,nr
             v(jj)=-999.99
220       continue

!          write(*,*)' xla2,xla1,dht2(1),dht1(1),v(1) '
!          write(*,*) xla2,xla1,dht2(1),dht1(1),v(1) 
!          write(33,*)' xla2,xla1,dht2(1),dht1(1),v(1) '
!          write(33,*) xla2,xla1,dht2(1),dht1(1),v(1) 
!          write(33,*)' xla2,xla1,dht2(30),dht1(30),v(30) '
!          write(33,*) xla2,xla1,dht2(30),dht1(30),v(30) 

          do 205 i=1,nr
205        sva(i,j-1)=v(i)

200       xla1=xla2

          do 210 i=1,nr
210        dht1(i)=dht2(i)   

90     continue 
!
! have one fewer grid point because of the bisection
        ncm1=nc-1      
        write(17,'(2i6,2f8.2,2f8.0,i3)')ncm1,nr,xl+.5*dx,xr-.5*dx,
     $                 yb,yt,lev0
        write(18,'(2i6,2f8.2,2f8.0)')nc,nr,xl,xr,yb,yt      
        do 80 i=1,nr
          tpud(i)=0.
!          write (*,*) ' writing row',i,' of',nr
	  do 85 j=1,ncm1
	  vr(j)=sva(i,j)
	  if(vr(j).ne.-999.99)tpud(i)=tpud(i)+vr(j)*dis1(j)/1.e3
85	  continue
! write tpuda.dat file
	  write(15,'(f12.4,f8.0)')tpud(i),d(i)
          if(i.ne.1.and.i.ne.nr)ttot=ttot+0.1*tpud(i)
          if(i.eq.1)ttot=0.05*tpud(i)
          if(i.eq.nr)ttot=ttot+0.05*tpud(i)
          if(i.eq.nr)write(15,'(a20,f12.4,a6,i3,a8,f5.1)')
     $      ' total transport =  ',ttot,' lev0=',lev0,' escale=',escale
! write vel file
          write(17,'(10f8.2)')(vr(j),j=1,ncm1)
! 1feb2011 LL write dynamic ht 
          write(18,'(10f8.4)')(dynht(i,j),j=1,nc)

80      continue 
        open(66,file='dis1',form='formatted',status='unknown')
        write(66,566)(dis1(i),i=1,nc)
566     format(8f10.3)
        go to 599
16      stop 'error opening trkpos.txt, run mapxbt3.x on del to create'
578       stop 'error reading xbtinfo.p09'
599     continue
        write(*,*)
        write(*,*) 'Output written to gvdel.log'
        stop
        end      
c ************************************************************
        subroutine dyndp(d,delta,dyn,n)     
! input: n = nr (number of rows)
! input: d(1:n) (recall depth of row 1:n, d(1)=0.0, d(2) = 10.0, etc d(86)=850.0
! input delta = that's sva aka del grid, just passing in 1 column of del grid.
! output: dyn(i) dyn(1)=0.0 then calculate the rest - appears to be taking 
!    average of 2 dep grid pts going down water column and multiplying by depth.
!   a "dynamic height" I believe.
        dimension d(1),delta(1),dyn(1)      
        dyn(1)=0.
        do 1 i=2,n        
         dyn(i)=dyn(i-1)+.5*(delta(i)+delta(i-1))*(d(i)-d(i-1))
!         write(33,*)'dyn=',dyn(i),delta(i),delta(i-1),d(i), d(i-1)
1       continue
        return
        end
c ************************************************************
      SUBROUTINE GVEL(ALAT,ALAT1,DIST,DH,DH1,ISIGN,GVE,IDIM,B,LEV0,
     $NROWS)
! DIST    = distance between ALAT and ALAT1
!           CHECK ALATS are 2 tem/sal grid points? OR are
!                 ALATS one tem/sal and one vel grid point? 
! DH, DH1 = dynamic ht (output of dyndp) for ALAT and ALAT1-> 2 tem/sal grid points
! IDIM    = min(81,idim1) where idim1 is returned from sub DIMV -> 
!           currently just use 81, however perhaps try getting the row
!           number of the shallowest neighboring xbt to the grid point.
!           10may2013 idim1=nr (n rows in del file) for ibotuse=2, default now
!                     of filling del file routine.
! ISIGN   =  1 'lon' cruises in Northern Hem
!         =  1 'lat' cruises in Southern Hem
!         = -1 'lon' cruises in Southern Hem
!         = -1 'lat' cruises in Northern Hem
! B = set to zero in main
! LEV0 = set to 81
! NROWS = number of rows in .del file (match .tem/.sal, usually 86)
!
        DIMENSION DH(1),DH1(1),GVE(1)       
        RLAT=ABS(1.7453293E-2*ALAT)
        RLAT1=ABS(1.7453293E-2*ALAT1)       
! This is probably coriolis parameter: and it needs latitudes:
        corp=1.458422e-4*sin(.5*(rlat+rlat1))*dist
        CORP=1./CORP
        write(33,*)'corp in gvel=',corp, alat, alat1
!
        DO 4 I=1,IDIM
         write(33,*)'i,dh(i),dh1(i),isign',i,dh(i),dh1(i),isign
4        GVE(I)=(DH(I)-DH1(I))*CORP*ISIGN    
        MDIM=MIN(IDIM,LEV0)        
!
        DEL=GVE(MDIM)     
        write(33,*)'mdim in gvel=',mdim,' del=',del
!
        DO 10 I=1,IDIM    
          GVE(I)=-GVE(I)+DEL+B       
! p05 vals near equator too large for my vel format, so set them to max size:
          if(gve(i).lt.-9999.99) gve(i) = -9999.99
10      continue

        IDP1=IDIM+1       
        if(idp1.ge.nrows)go to 21
!                                
! this is just filling in data below lev0 (81) with -999.99
        DO 20 I=IDP1,NROWS
20      GVE(I)=-999.99
21      RETURN   
        END      
! ************************************************************
        SUBROUTINE DIMV(XG,BD,XPDR,DY,NPDR,IDIM)     
! Find row number of bottom depth at vel grid point
! Input can be individual cruise bathy or a generic line bathy
        DIMENSION BD(1),XPDR(1)    
        I=1      
        DO 10 J=2,NPDR    
10      IF(XG.GT.XPDR(J))I=I+1     
        XPO=(XG-XPDR(I))/(XPDR(I+1)-XPDR(I))
        BDEP=BD(I)+XPO*(BD(I+1)-BD(I))      
        IDIM=INT(BDEP/DY)+1        
        RETURN   
        END      
! ************************************************************
