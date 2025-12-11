! subroutine to create ferret.tem.a and new ferret.web files
! for xbt cruises -Called from mapxbt3.f
! 
! 55 = ferret.tem - suitable for color postscript output
! 65 = fer.web - must create metafile.plt - then ps file, then
!       use /usr/local/bin/fatps it, then crop and gif it for website.
!
! 13Nov2025 - BRZENSKI - modified to use pyFerret
!
       subroutine fertem(fnam,typ,irow,icol,xleft,xright,ixbt1,ixbt2,
     $                    shipname,iendpoint,istartpoint,ship2,orient,
     $                    l1,l2,nsta)
       character typ*3, outfile*13, adate*23, ship*24
       character*12 fnam, axlat*48, axlon*50, ahem*1, axlonb*51
       character path1*39, path2*33, topofile*39, b1*41,b2*27, b3*31
       character level1*59, shipname*30, ship2*20, q*1
       character*45 levp09,levp15,levp28,levp31,levp34,levp37,levp22
       character*45 levi21
       character*45 levp81,levp38,levp50, over*43, tc*55, tc1*35
       character*45 levp08,levp40
       character*3 orient, shakey*43, ps*9, pcn*19, conset*29
       character topo1*31, topo2*33, fdat*11, pathp28*34,tcp28*56
       character origin*18, webfile*10, overw*43
       character chileblank1*26, chileblank2*39
       character ngoodsta*14

        data topofile/'file/var=bath/skip=1/col= 395/grid=topo'/
!                      12345678901234567890123456789012345678901234567890123456789
        data outfile/'ferret.tem.g '/, q/'"'/
       data webfile/'fertem.web'/
       data fdat/'p099510.dat'/
       data axlat/'define axis/y=35.65S:48.15N:.1/units=degrees lat'/
       data axlon/'define axis/x= 31.55E:115.55E:.1/units=degrees lon'/
       data axlonb/
     $'define axis/x= 31.55E:115.55E:.1/units=degrees ybot'/
       data path1/'file/var=p09/col=    /skip=1/grid=tem1 '/
       data path2/'"/data/xbt/p09/9509/p099509a.tem"'/
       data pathp28/'"/data/xbt/p09/9502b/p099502b.tem"'/
       data b1/'                                         '/
       data b3/' "/data/xbt/s37/0811/bath1.grd"'/
!                12345678901234567890123456789012345678901234567890123456789
       data level1/
     $'shade/set_up/nolab/hlim= 21.50N: 61.00N/vlim=-20:800/levels'/
!      12345678901234567890123456789012345678901234567890123456789
!               1         2         3         4         5
       data levp09/'="(3.6,7.,.1) (7.,20.,1.) (20.,30.5,.5)" p09 '/
       data levp15/'="(4.,7.,.1) (7.,20.,1.) (20.,28.5,.5)" p15  '/
       data levi21/'="(4.,7.,.1) (7.,20.,1.) (20.,30.5,.5)" i21  '/
       data levp81/'="(4.,7.,.1) (7.,20.,1.) (20.,30.5,.5)" p81  '/
        data levp22/'="(-2.0,4.,.1) (4.,10.,.25)" p22             '/
       data levp28/'="(-1.9,4.,.1) (4.,17.,.25)" p28             '/
! old       data levp31/'="(4.2,10.,.2) (10.,28.,.5)" p31             '/
       data levp31/'="(4.2,10.,.2) (10.,30.5,.5)" p31            '/
       data levp34/'="(4.2,10.,.2) (10.,27.5,.5)" p34            '/
       data levp37/'="(3.8,6.,.1) (6.,20.,1.) (20.,30.5,.5)" p37 '/
!                    12345678901234567890123456789012345678901234567890123456789
       data levp40/'="(3.0,6.,.1) (6.,20.,1.) (20.,30.5,.5)" p40 '/
!                    123456789012345678901234567890123456789012345678901234
       data levp38/'="(2.9,6.,.10) (6.,10.,.2) (10.,27.5,.5)" p38'/
       data levp50/'="(4.,7.,.1) (7.,20.,1.) (20.,26.,.5)" p50   '/
       data levp08/'="(4.,7.,.1) (7.,20.,1.) (20.,30.5,.5)" p08  '/
       data over/'contour/set_up/overlay/nolab/color=7/level='/
       data overw/'contour/set_up/overlay/nolab/color=1/level='/
       data tc/'file/var="lat,depth" "/data/xbt/p09/9510/station.tics"'/
c               123456789012345678901234567890123456789012345678901234
       data tcp28
     $  /'file/var="lat,depth" "/data/xbt/p28/9502b/station.tics"'/
!         1234567890123456789012345678901234567890123456789012345
!      data tc1/'plot/over/nolab/line=7/vs lat,depth'/ !BRZENSKI
       data tc1/'plot/over/nolab/line=1/vs lat,depth'/
       data topo1/'define grid/y=ybot/z=depth topo'/
       data topo2/'define grid/y=ybot2/z=depth topo2'/
c                   1234567890123456789012345678901234567890
       data shakey/'ppl shakey 1,1,.10,0,,4,11.25,11.55,1.2,5.7'/ ! BRZENSKI .12->.10
       data ps/'ppl shade'/
       data pcn/'ppl contour/overlay'/
       data conset/'ppl conset .13,0,0.5,,,,,8.,1.,1'/ ! BRZENSKI added 0.5 as 3rd arg
       data origin/'ppl origin 1.0,1.2'/
       data chileblank1/'set region/y=37.00S:35.00S'/
       data chileblank2/'shade/over/nolab/palette=white p81[d=1]'/
c                         123456789012345678901234567890123456789
       data ngoodsta/'Good drops=   '/
c                      123456789012345678901234567890123456789

c outfile = ferret control file
       outfile(8:10) = typ(1:3)
       webfile(4:6) = typ(1:3)
       outfile(12:12) = fnam(8:8)
c # good stations:
       if(nsta.le.9) write(ngoodsta(14:14),'(i1)') nsta
       if(nsta.ge.10.and.nsta.le.99) write(ngoodsta(13:14),'(i2)') nsta
       if(nsta.ge.100.and.nsta.le.999)write(ngoodsta(12:14),'(i3)') nsta
CHECK CHECK CHECK
c next 3 lines temporary for redoing p22!!!
       if(fnam(1:3).eq.'p22') then
          outfile(1:13) = 'new_tem.fer  '
       endif
       open(55,file=outfile,form='formatted',status='unknown')
       open(65,file=webfile,form='formatted',status='unknown')
c next lines common to all cruise lines
       write(55,'(a14)')'PPL DFLTFNT DR'
       write(65,'(a14)')'PPL DFLTFNT DR'
       write(55,'(a15)')'PALETTE rainbow' ! BRZENSKI
       write(65,'(a15)')'PALETTE rainbow' ! BRZENSKI
       write(55,'(a17)')'ppl conpre @P1@DR'
       write(65,'(a17)')'ppl conpre @P1@DR'
       write(55,'(a19)')'ppl axlsze 0.17,.17'
       write(65,'(a19)')'ppl axlsze 0.17,.17'
       write(55,'(a17)')'ppl axset 0,1,1,1'
       write(65,'(a17)')'ppl axset 0,1,1,1'
c  pen 0=axis&labels
       write(55,'(a12)')'ppl pen 0,0        ! white background' ! BRZENSKI
       write(65,'(a12)')'ppl pen 0,0        ! white background' ! BRZENSKI
       write(55,'(a12)')'ppl pen 1,1        ! black text' ! BRZENSKI
       write(65,'(a12)')'ppl pen 1,1        ! black text' ! BRZENSKI
       write(55,'(a22)')'ppl labset .17,.17,.17,.17'
       write(65,'(a22)')'ppl labset .17,.17,.17,.17'
       write(55,*)
       write(65,*)

c only going to depth=760 in p28, depth=800 all other line
c define z axis
       if(fnam(1:3).eq.'p28') then
          write(55,'(a)')'define axis/z=0:760:10/units=m/depth depth'
          write(65,'(a)')'define axis/z=0:760:10/units=m/depth depth'
c 03feb2004 - p08 Mairangi goes too fast, only a few drops to 800m.
c most cat at 700-750
       elseif(fnam(1:3).eq.'p08') then
          write(55,'(a)')'define axis/z=0:760:10/units=m/depth depth'
          write(65,'(a)')'define axis/z=0:760:10/units=m/depth depth'
       else
          write(55,'(a)')'define axis/z=0:800:10/units=m/depth depth'
          write(65,'(a)')'define axis/z=0:800:10/units=m/depth depth'
       endif

c this if separates latitude and longitude cruises
c define (y=lat, x=lon) axis from passed in lat/lon endpoints
       if(orient.eq.'lat') then
          ahem = 'N'
          if(xleft.lt.0.0) ahem = 'S'
          write(axlat(15:19),'(f5.2)') abs(xleft)
          write(axlat(20:20),'(a1)') ahem(1:1)
          ahem = 'N'
          if(xright.lt.0.0) ahem = 'S'
          write(axlat(22:26),'(f5.2)') abs(xright)
          write(axlat(27:27),'(a1)') ahem(1:1)
          write(55,'(a)') axlat(1:48)
          write(55,'(a)')'define grid/y=lat/z=depth tem1'
          write(65,'(a)') axlat(1:48)
          write(65,'(a)')'define grid/y=lat/z=depth tem1'
       else
          ahem = 'E'
          write(axlon(15:20),'(f6.2)') abs(xleft)
          write(axlon(21:21),'(a1)') ahem(1:1)
          write(axlon(23:28),'(f6.2)') abs(xright)
          write(axlon(29:29),'(a1)') ahem(1:1)
          write(55,'(a)') axlon(1:50)
          write(55,'(a)')'define grid/x=lon/z=depth tem1'
          write(65,'(a)') axlon(1:50)
          write(65,'(a)')'define grid/x=lon/z=depth tem1'
       endif
c grid file information, writing how many columns (from mapxbt3) to read
c plus path to file
       write(path1(10:12),'(a3)') fnam(1:3)
       write(path1(18:21),'(i4)') icol
       write(topofile(26:29),'(i4)') icol
       write(path2(12:14),'(a3)') fnam(1:3)
       if(fnam(1:3).eq.'p13') then
          write(path1(10:12),'(a3)')'p09'
          write(path2(12:14),'(a3)')'p09'
       endif
       write(path2(16:19),'(a4)') fnam(4:7)
c p28 different path since a,b,c, etc is actually in path, not only filename
c tc, tcp28 are path names to station.tics
       if(fnam(1:3).eq.'p28'.or.fnam(1:3).eq.'p06') then
          write(pathp28(12:14),'(a3)') fnam(1:3)
          write(pathp28(16:20),'(a5)') fnam(4:8)
          write(pathp28(22:29),'(a8)') fnam(1:8)
          write(55,'(a,a)') path1(1:39), pathp28(1:34)
          write(65,'(a,a)') path1(1:39), pathp28(1:34)

          write(tcp28(37:41),'(a5)') fnam(4:8)
       else
          write(path2(21:28),'(a8)') fnam(1:8)
          write(55,'(a,a)') path1(1:39), path2(1:33)
          write(65,'(a,a)') path1(1:39), path2(1:33)

          write(tc(33:35),'(a3)') fnam(1:3)
          if(fnam(1:3).eq.'p13') write(tc(33:35),'(a3)')'p09'
          write(tc(37:40),'(a4)') fnam(4:7)
       endif
c all cruises:
       write(55,'(a)') 'set win/siz=2.0/asp=0.6'
       write(55,'(a)') origin
       write(65,'(a)') 'set win/siz=2.0/asp=0.6'
       write(65,'(a)') origin
c open stations.dat to read dates of cruise - passing in ixbt1&ixbt2(mapxbt3)
c as first and last drop number used in grid file       
       fdat(1:7) = fnam(1:7)
       print *, 'ixbt1=',ixbt1,' ixbt2=',ixbt2
       open(56,file=fdat,status='old',form='formatted')
       print *, 'reading=',fdat
       do 100 i = 1, 400
          read(56,500,end=101) idrop, idy, imo, iyr
!          print*,  idrop, idy, imo, iyr
          if(idrop.eq.ixbt1) then
             idy1 = idy
             imo1 = imo
             iyr1 = iyr
          elseif(idrop.eq.ixbt2) then
             idy2 = idy
             imo2 = imo
             iyr2 = iyr
             go to 101
          endif
100       continue
500       format(i4,14x,i2,1x,i2,1x,i2)
101       continue
       close(56)
c pass dates to subroutine date to write character string of cruise dates
       call makedate(idy1,idy2,imo1,imo2,iyr1,iyr2,adate)

c this if then, elseif then, etc has a section for each cruise line,
c some stuff is identical, but it seemed easier to finish writing the
c ferret file here

c p08
       if(fnam(1:3).eq.'p08') then
          write(level1(25:39),'(a15)') '171.00E: 80.00W'
         if(iendpoint.eq.1) write(level1(27:27),'(a1)') '6'
         icenter = 225
          write(55,'(a,a)') level1(1:59), levp08(1:45)
          write(65,'(a,a)') level1(1:59), levp08(1:45)
          write(55,'(a)')shakey
          write(65,'(a)')shakey
          write(55,'(a)')ps
          write(65,'(a)')ps
          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p08'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p08'
          write(55,'(a)')conset
          write(65,'(a)')conset
          write(55,'(a)')pcn
          write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
c bottom topo goes here, once I have one...
             write(55,'(a)')
     $       'define axis/x=171.07E:280.07E:.1/units=degrees ybot'
             write(65,'(a)')
     $       'define axis/x=171.07E:280.07E:.1/units=degrees ybot'
             write(topo1(13:13),'(a1)')'x'
             write(55,'(a)') topo1(1:31)
             write(65,'(a)') topo1(1:31)
             b1(1:41) = 'file/var=bathdp/skip=1/col=1091/grid=topo'
             b2(1:27) = ' "/data/xbt/p08/bathdp.grd"'
             write(55,'(a,a)')b1, b2
             write(65,'(a,a)')b1, b2
             write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathdp'
             write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathdp'

c labels:
         if(iendpoint.eq.1) then
          write(55,'(a)')'label 175,-30,0,0,.2,Auckland'
          write(65,'(a)')'label 175,-30,0,0,.2,Auckland'
         elseif(iendpoint.eq.2) then
          write(55,'(a)')'label 175,-30,0,0,.2,Dunedin'
          write(65,'(a)')'label 175,-30,0,0,.2,Dunedin'
         endif
          write(55,'(a)')'label 281,-30,0,0,.2,Panama'
          write(65,'(a)')'label 281,-30,0,0,.2,Panama'
          ship(1:24) = 'label    ,980,0,0,.19, "'
         write(ship(7:9),'(i3)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
c p09
       elseif(fnam(1:3).eq.'p09'.or.fnam(1:3).eq.'p13') then
c write plot bounds 
          if(iendpoint.eq.1) then
             write(level1(25:39),'(a15)') ' 36.00S: 18.00S'
             icenter = -27
          elseif(iendpoint.eq.2.or.iendpoint.eq.3) then
             write(level1(25:39),'(a15)') ' 36.00S: 21.35N'
             icenter = -7
          elseif(iendpoint.eq.4) then
             write(level1(25:39),'(a15)') ' 36.00S: 48.25N'
             icenter = 6
          elseif(iendpoint.eq.5.or.iendpoint.eq.6.
     $             or.iendpoint.eq.7.or.iendpoint.eq.8.
     $             or.iendpoint.eq.9.or.iendpoint.eq.10) then
             write(level1(25:39),'(a15)') ' 36.00S: 34.25N'
             icenter = -1 
          else
             stop 'define p09 shade limits in mapxbt3.f'
          endif

          write(55,'(a,a)') level1(1:59), levp09(1:45)
          write(65,'(a,a)') level1(1:59), levp09(1:45)
          write(55,'(a)')shakey
          write(65,'(a)')shakey
          write(55,'(a)')ps
          write(65,'(a)')ps
          write(55,'(a,a33)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p09'
          write(65,'(a,a33)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p09'
          write(55,'(a)')conset
          write(65,'(a)')conset
          write(55,'(a)')pcn
          write(65,'(a)')pcn
          write(55,*)
          write(65,*)
c station.tics
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
c bottom topography
          if(iendpoint.eq.1.or.iendpoint.eq.3.or.iendpoint.eq.4.
     $        or.iendpoint.eq.5.or.iendpoint.eq.6.
     $        or.iendpoint.eq.7) then
           write(55,'(a)')
     $      'define axis/y=35.9S:18.0S:.1/units=degrees ybot2'
           write(65,'(a)')
     $      'define axis/y=35.9S:18.0S:.1/units=degrees ybot2'
           write(55,'(a)') topo2(1:33)
           write(65,'(a)') topo2(1:33)
           b1(1:41) = 'file/var=bathas/skip=1/col=180/grid=topo2'
           b2(1:27) = ' "/data/xbt/p09/bathas.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathas'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathas'
           write(55,*)
           write(65,*)
! no SUVA:
          elseif(iendpoint.eq.2.or.iendpoint.eq.8.or.iendpoint.eq.9.or.
     $           iendpoint.eq.10) then
           write(55,'(a)')
     $      'define axis/y=35.85S:21.25N:.1/units=degrees ybot2'
           write(65,'(a)')
     $      'define axis/y=35.85S:21.25N:.1/units=degrees ybot2'
           write(55,'(a)') topo2(1:33)
           write(65,'(a)') topo2(1:33)
           b1(1:41) = 'file/var=bathah/skip=1/col=572/grid=topo2'
           b2(1:27) = ' "/data/xbt/p09/bathah.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathah'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathah'
           write(55,*)
           write(65,*)
          endif
          if(iendpoint.eq.4.or.iendpoint.eq.3.or.iendpoint.eq.5) then
           write(55,'(a49)')
     $      'define axis/y=18.15S:48.25N:.1/units=degrees ybot'
           write(65,'(a49)')
     $      'define axis/y=18.15S:48.25N:.1/units=degrees ybot'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
           b1(1:41) = 'file/var=bathss/skip=1/col=665/grid=topo '
           b2(1:27) = ' "/data/xbt/p09/bathss.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathss'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathss'
          endif
c plot labels
          if(iendpoint.ne.7.and.iendpoint.ne.10) then
             write(55,'(a)')'label -35,-30,0,0,.2,Auckland'
             write(65,'(a)')'label -35,-30,0,0,.2,Auckland'
          else
             write(55,'(a)')'label -35,-30,0,0,.2,Tauranga'
             write(65,'(a)')'label -35,-30,0,0,.2,Tauranga'
          endif
          if(iendpoint.ne.2.and.iendpoint.ne.8) then
             write(55,'(a)')'label -18,-30,0,0,.2,Suva'
             write(65,'(a)')'label -18,-30,0,0,.2,Suva'
          endif
          if(iendpoint.eq.3.or.iendpoint.eq.2) then
             write(55,'(a)')'label 21,-30,0,0,.2,Hawaii'
             write(65,'(a)')'label 21,-30,0,0,.2,Hawaii'
          endif
          if(iendpoint.eq.4) then
             write(55,'(a)')'label 48,-30,0,0,.2,Seattle'
             write(65,'(a)')'label 48,-30,0,0,.2,Seattle'
          endif
          if(iendpoint.eq.5.or.iendpoint.eq.6.
     $         or.iendpoint.eq.7.or.iendpoint.eq.8.or.
     $         iendpoint.eq.10) then
             write(55,'(a)')'label 32,-30,0,0,.2,Los Angeles'
             write(65,'(a)')'label 32,-30,0,0,.2,Los Angeles'
          endif
          if(iendpoint.eq.9) then
             write(55,'(a)')'label 32,-30,0,0,.2,San Francisco'
             write(65,'(a)')'label 32,-30,0,0,.2,San Francisco'
          endif

          ship(1:23) = 'label   ,980,0,0,.19, "'
          if(icenter.ge.0.and.icenter.le.9)
     $          write(ship(8:8),'(i1)') icenter
          if(icenter.ge.10) write(ship(7:8),'(i2)') icenter
          if(icenter.lt.0) write(ship(7:8),'(i2)') icenter
          write(*,*)'icenter=',icenter,' ship=',ship
          write(55,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
c i21
       elseif(fnam(2:3).eq.'21') then
! 05sep2013 151.35E:173.85E current tem file bounds, only reren 1305&08
          write(level1(25:39),'(a15)') ' 31.65E: 57.35E'
          write(55,'(a,a)') level1(1:59), levi21(1:45)
          write(65,'(a,a)') level1(1:59), levi21(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" i21'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" i21'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
           write(55,'(a)') axlonb
           write(65,'(a)') axlonb
          write(topo1(13:13),'(a1)')'x'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)
           b3(1:31) = ' "/data/xbt/i21/0811/batha.grd"'
           b3(17:20) = fnam(4:7)
          write(55,'(a,a)')topofile, b3
          write(65,'(a,a)')topofile, b3
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(55,*)
          write(65,*)
          write(55,'(a28)')'label 31.5,-30,0,0,.2,Durban'
          write(65,'(a28)')'label 31.5,-30,0,0,.2,Durban'
          write(55,'(a31)')'label 56.5,-30,0,0,.2,Mauritius'
          write(65,'(a31)')'label 56.5,-30,0,0,.2,Mauritius'
          icenter = xleft + (xright - xleft)/2.0    !??
          ship(1:24) = 'label  45,980, 0,0,.2, "'
!nogo:          write(ship(7:8),'(i2)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
!
!
!
!
       elseif(fnam(1:3).eq.'p15') then
          write(level1(25:39),'(a15)') axlon(15:30)
!          icenter = 73
          icenter = xleft + (xright - xleft)/2.0
          write(55,'(a59,a45)') level1(1:59), levp15(1:45)
          write(65,'(a59,a45)') level1(1:59), levp15(1:45)
          write(55,'(a)')shakey
          write(65,'(a)')shakey
          write(55,'(a)')ps
          write(65,'(a)')ps
          write(55,'(a,a33)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p15'
          write(65,'(a,a33)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p15'
          write(55,'(a)')conset
          write(65,'(a)')conset
          write(55,'(a)')pcn
          write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a54)') tc(1:54)
          write(65,'(a54)') tc(1:54)
          write(55,'(a35)') tc1(1:35)
          write(65,'(a35)') tc1(1:35)
          write(55,*)
          write(65,*)
          write(55,'(a48)')
     $     'define axis/x=31.4E:115.2E:.1/units=degrees ybot'
          write(65,'(a48)')
     $     'define axis/x=31.4E:115.2E:.1/units=degrees ybot'
          write(topo1(13:13),'(a1)')'x'
          write(55,'(a31)') topo1(1:31)
          write(65,'(a31)') topo1(1:31)
          b1(1:40) = 'file/var=bathdf/skip=1/col=839/grid=topo'
          b2(1:27) = ' "/data/xbt/p15/bathdf.grd"'
          write(55,'(a40,a27)')b1, b2
          write(65,'(a40,a27)')b1, b2
          write(55,'(a63)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathdf'
          write(65,'(a63)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathdf'
          write(55,*)
          write(65,*)
          write(55,'(a)')'label 30,-30,0,0,.2,Durban'
          write(65,'(a)')'label 30,-30,0,0,.2,Durban'
          write(55,'(a)')'label 111,-30,0,0,.2,Fremantle'
          write(65,'(a)')'label 111,-30,0,0,.2,Fremantle'
          ship(1:23) = 'label   ,980,0,0,.19, "'
          write(ship(7:8),'(i2)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
             write(33,*)'#',ship2(1:l1),'#'
c p22
        elseif(fnam(1:3).eq.'p22') then
c iendpoint=1=Palmer
          if(iendpoint.eq.1) then
             write(level1(25:39),'(a15)') ' 65.00S: 54.50S'
             icenter = 60
c iendpoint=2=Smith
          elseif(iendpoint.eq.2) then
             write(level1(25:39),'(a15)') ' 64.00S: 54.50S'
             icenter = 59
c iendpoint=3=King George
          elseif(iendpoint.eq.3) then
             write(level1(25:39),'(a15)') ' 62.00S: 54.50S'
             icenter = 58
          else
             stop 'define p22 shade limits in mapxbt3.f'
          endif

           write(55,'(a,a)') level1(1:59), levp22(1:45)
           write(65,'(a,a)') level1(1:59), levp22(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(-2,30,1,1) DARK(0,30,5,1)" p22 '
           write(65,'(a,a)')overw(1:43),
     $                       '"(-2,30,1,1) DARK(0,30,5,1)" p22 '
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a)') tc(1:55)
           write(65,'(a)') tc(1:55)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(55,'(a)')'label -54,-30,1,0,.2,Isla de los Estados'
           write(65,'(a)')'label -54,-30,1,0,.2,Isla de los Estados'
           ship(1:23) = 'label -  ,950,0,0,.2, "'
          write(ship(8:9),'(i2)') icenter
c iendpoint=1=Palmer
          if(iendpoint.eq.1) then
              write(55,'(a)')'label -65.8,-30,-1,0,.2,Palmer Station'
              write(65,'(a)')'label -65.8,-30,-1,0,.2,Palmer Station'
c iendpoint=2=Smith
          elseif(iendpoint.eq.2) then
              write(55,'(a)')'label -64.8,-30,-1,0,.2,Smith Island'
              write(65,'(a)')'label -64.8,-30,-1,0,.2,Smith Island'
c iendpoint=3=King George
          elseif(iendpoint.eq.3) then
              write(55,'(a)')'label -62.5,-30,-1,0,.2,King George'
              write(65,'(a)')'label -62.5,-30,-1,0,.2,King George'
          endif

          write(55,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
c p28
       elseif(fnam(1:3).eq.'p28') then
          write(level1(25:39),'(a15)') ' 66.20S: 43.60S'
          write(55,'(a59,a45)') level1(1:59), levp28(1:45)
          write(65,'(a59,a45)') level1(1:59), levp28(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps
          write(55,'(a,a33)')over(1:43),
     $                       '"(-2,30,1,1) DARK(0,30,5,1)" p28 '
          write(65,'(a,a33)')overw(1:43),
     $                       '"(-2,30,1,1) DARK(0,30,5,1)" p28 '
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tcp28(1:55)
          write(65,'(a)') tcp28(1:55)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
          write(55,'(a)')'label -67,-30,-1,0,.2,Dumont d''''Urville'
          write(65,'(a)')'label -67,-30,-1,0,.2,Dumont d''''Urville'
          write(55,'(a)')'label -43,-30,1,0,.2,Hobart'
          write(65,'(a)')'label -43,-30,1,0,.2,Hobart'
          ship(1:24) = 'label -67,980,-1,0,.2, "'
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
       elseif(fnam(1:3).eq.'p06') then
!   Auckland - Noumea - Lautoka
            if(iendpoint.eq.2) then
              write(level1(25:39),'(a15)') ' 36.00S: 22.00S'
            elseif(iendpoint.eq.3) then
              write(level1(25:39),'(a15)') '166.00E:178.00E'
            elseif(iendpoint.eq.4) then
              write(level1(25:39),'(a15)') ' 36.00S: 18.00S'
            endif
           write(levp31(31:33),'(a3)') 'p06'
           write(55,'(a59,a45)') level1(1:59), levp31(1:45)
           write(65,'(a59,a45)') level1(1:59), levp31(1:45)
            write(55,'(a)')shakey
            write(65,'(a)')shakey
            write(55,'(a)')ps
            write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p06'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p06'
            write(55,'(a)')conset
            write(65,'(a)')conset
            write(55,'(a)')pcn
            write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(tcp28(33:35),'(a3)') 'p06'
           write(55,'(a)') tcp28(1:55)
           write(65,'(a)') tcp28(1:55)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
!           write(55,'(a)')
!     $      'define axis/y= 36.0S: 18.0S:.1/units=degrees ybot'
!           write(65,'(a)')
!     $      'define axis/y= 36.0S: 18.0S:.1/units=degrees ybot'
!           write(topo1(13:13),'(a1)')'y'
!           write(55,'(a)') topo1(1:31)
!           write(65,'(a)') topo1(1:31)
!           b1(1:41) = 'file/var=bathb1/skip=1/col=242/grid=topo '
!           b2(1:27) = ' "/data/xbt/p31/bathb1.grd"'
!           write(55,'(a,a)')b1, b2
!           write(65,'(a,a)')b1, b2
!           write(55,'(a)')
!     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb1'
!           write(65,'(a)')
!     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb1'
!           write(55,*)
!           write(65,*)
           ship(1:24) = 'label -27,980,0,0,.2, "'
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          if(iendpoint.eq.2) then
           write(55,'(a)')'label -37,-30,-1,0,.2,Auckland'
           write(65,'(a)')'label -37,-30,-1,0,.2,Auckland'
           write(55,'(a)')'label -22,-30,0,0,.2,Noumea'
           write(65,'(a)')'label -22,-30,0,0,.2,Noumea'
          elseif(iendpoint.eq.3) then
           write(55,'(a)')'label 166,-30,-1,0,.2,Noumea'
           write(65,'(a)')'label 166,-30,-1,0,.2,Noumea'
           write(55,'(a)')'label 178,-30,1,0,.2,Lautoka'
           write(65,'(a)')'label 178,-30,1,0,.2,Lautoka'
          elseif(iendpoint.eq.1.or.iendpoint.eq.4) then
           write(55,'(a)')'label -37,-30,-1,0,.2,Auckland'
           write(65,'(a)')'label -37,-30,-1,0,.2,Auckland'
           write(55,'(a)')'label -17.5,-30,1,0,.2,Suva   '
           write(65,'(a)')'label -17.5,-30,1,0,.2,Suva   '

           endif
! p31
       elseif(fnam(1:3).eq.'p31') then
! use iendpoint entered above to determine what to write on the plot
          if(iendpoint.eq.1) then
!   b1  Brisbane - Noumea - Lautoka '
           write(level1(25:39),'(a15)') '153.30E:177.40E'
           write(55,'(a59,a45)') level1(1:59), levp31(1:45)
           write(65,'(a59,a45)') level1(1:59), levp31(1:45)
            write(55,'(a)')shakey
            write(65,'(a)')shakey
            write(55,'(a)')ps
            write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
            write(55,'(a)')conset
            write(65,'(a)')conset
            write(55,'(a)')pcn
            write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a)') tc(1:54)
           write(65,'(a)') tc(1:54)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
           write(55,'(a)') axlonb
           write(65,'(a)') axlonb
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
           b1(1:41) = 'file/var=bathb1/skip=1/col=   /grid=topo '
           write(b1(28:30),'(i3)') icol
           b3(1:27) = ' "/data/xbt/p31/0000/bath1.grd"'
           b3(17:20) = fnam(4:7)
           write(55,'(a,a)')b1, b3
           write(65,'(a,a)')b1, b3
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb1'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb1'
           write(55,*)
           write(65,*)
           ship(1:24) = 'label 152,980,-1,0,.2, "'
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(55,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(65,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(55,'(a)')'label 165,-30,-1,0,.2,Noumea'
           write(65,'(a)')'label 165,-30,-1,0,.2,Noumea'
           write(55,'(a)')'label 178,-30,1,0,.2,Lautoka'
           write(65,'(a)')'label 178,-30,1,0,.2,Lautoka'
          elseif(iendpoint.eq.2) then
!   b2  Brisbane - Noumea - Suva 
           write(level1(25:39),'(a15)') '153.30E:178.40E'
           write(55,'(a,a)') level1(1:59), levp31(1:45)
           write(65,'(a,a)') level1(1:59), levp31(1:45)
            write(55,'(a)')shakey
            write(65,'(a)')shakey
            write(55,'(a)')ps
            write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
            write(55,'(a)')conset
            write(65,'(a)')conset
            write(55,'(a)')pcn
            write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a54)') tc(1:54)
           write(65,'(a54)') tc(1:54)
           write(55,'(a35)') tc1(1:35)
           write(65,'(a35)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(55,'(a)')
     $      'define axis/x=153.3E:178.5E:.1/units=degrees ybot'
           write(65,'(a)')
     $      'define axis/x=153.3E:178.5E:.1/units=degrees ybot'
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
           b1(1:40) = 'file/var=bathb2/skip=1/col=253/grid=topo'
           b2(1:27) = ' "/data/xbt/p31/bathb2.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb2'
           write(55,*)
           write(65,*)
           ship(1:24) = 'label 152,980,-1,0,.2, "'
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(55,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(65,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(55,'(a)')'label 165,-30,-1,0,.2,Noumea'
           write(65,'(a)')'label 165,-30,-1,0,.2,Noumea'
           write(55,'(a)')'label 179,-30,1,0,.2,Suva   '
           write(65,'(a)')'label 179,-30,1,0,.2,Suva   '
          elseif(iendpoint.eq.3) then
!  b3  Brisbane - Lautoka '
           write(level1(25:39),'(a15)') '153.30E:177.40E'
           write(55,'(a,a)') level1(1:59), levp31(1:45)
           write(65,'(a,a)') level1(1:59), levp31(1:45)
            write(55,'(a)')shakey
            write(65,'(a)')shakey
            write(55,'(a)')ps
            write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
            write(55,'(a)')conset
            write(65,'(a)')conset
            write(55,'(a)')pcn
            write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a54)') tc(1:54)
           write(65,'(a54)') tc(1:54)
           write(55,'(a35)') tc1(1:35)
           write(65,'(a35)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(55,'(a)')
     $      'define axis/x=153.14E:177.34E:.1/units=degrees ybot'
           write(65,'(a)')
     $      'define axis/x=153.14E:177.34E:.1/units=degrees ybot'
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
           b1(1:40) = 'file/var=bathb3/skip=1/col=243/grid=topo'
           b2(1:27) = ' "/data/xbt/p31/bathb3.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb3'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb3'
           write(55,*)
           write(65,*)
           ship(1:24) = 'label 152,980,-1,0,.2, "'
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(55,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(65,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(55,'(a)')'label 178,-30,1,0,.2,Lautoka'
           write(65,'(a)')'label 178,-30,1,0,.2,Lautoka'
          elseif(iendpoint.eq.4) then
!   b4  Brisbane - Suva '
           write(level1(25:39),'(a15)') '153.30E:178.40E'
           write(55,'(a,a)') level1(1:59), levp31(1:45)
           write(65,'(a,a)') level1(1:59), levp31(1:45)
            write(55,'(a)')shakey
            write(65,'(a)')shakey
            write(55,'(a)')ps
            write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p31'
            write(55,'(a)')conset
            write(65,'(a)')conset
            write(55,'(a)')pcn
            write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a)') tc(1:54)
           write(65,'(a)') tc(1:54)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(55,'(a)')
     $      'define axis/x=153.14E:178.44E:.1/units=degrees ybot'
           write(65,'(a)')
     $      'define axis/x=153.14E:178.44E:.1/units=degrees ybot'
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
           b1(1:41) = 'file/var=bathb4/skip=1/col=254/grid=topo '
           b2(1:27) = ' "/data/xbt/p31/bathb4.grd"'
           write(55,'(a,a)')b1, b2
           write(65,'(a,a)')b1, b2
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb4'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathb4'
           write(55,*)
           write(65,*)
           ship(1:24) = 'label 152,980,-1,0,.2, "'
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(55,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(65,'(a)')'label 152,-30,-1,0,.2,Brisbane'
           write(55,'(a)')'label 179,-30,1,0,.2,Suva   '
           write(65,'(a)')'label 179,-30,1,0,.2,Suva   '

          endif
c p34
       elseif(fnam(1:3).eq.'p34') then
! 05sep2013 151.35E:173.85E current tem file bounds, only reren 1305&08
          write(level1(25:39),'(a15)') '151.35E:173.85E'
          write(55,'(a,a)') level1(1:59), levp34(1:45)
          write(65,'(a,a)') level1(1:59), levp34(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p34'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p34'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
           write(55,'(a)') axlonb
           write(65,'(a)') axlonb
          write(topo1(13:13),'(a1)')'x'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)
           b3(1:31) = ' "/data/xbt/p34/0811/bath1.grd"'
           b3(17:20) = fnam(4:7)
          write(55,'(a,a)')topofile, b3
          write(65,'(a,a)')topofile, b3
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(55,*)
          write(65,*)
          write(55,'(a28)')'label 150,-30,-1,0,.2,Sydney'
          write(65,'(a28)')'label 150,-30,-1,0,.2,Sydney'
          write(55,'(a31)')'label 173,-30,1,0,.2,Wellington'
          write(65,'(a31)')'label 173,-30,1,0,.2,Wellington'
          ship(1:24) = 'label 152,980,-1,0,.2, "'
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
! p37s
        elseif(fnam(1:3).eq.'s37') then
           write(level1(25:39),'(a15)') '202.00E:242.00E'
           icenter = 222
           levp37(42:42) = 's'
          write(55,'(a,a)') level1(1:59), levp37(1:45)
          write(65,'(a,a)') level1(1:59), levp37(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" s37'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" s37'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
          write(55,'(a)') axlonb
          write(65,'(a)') axlonb
          write(topo1(13:13),'(a1)')'x'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)
           b3(1:31) = ' "/data/xbt/s37/0811/bath1.grd" '
            b3(17:20) = fnam(4:7)
          write(55,'(a,a)')topofile, b3
          write(65,'(a,a)')topofile, b3
          write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(55,'(a)')'label 203,-40,0,0,.2,Hawaii'
          write(65,'(a)')'label 203,-40,0,0,.2,Hawaii'
           write(55,'(a)')'label 241,-40,0,0,.20 Long Beach'
           write(65,'(a)')'label 241,-40,0,0,.20 Long Beach'
          ship(1:24) = 'label 110,980,0,0,.18, "'
          write(ship(7:9),'(i3)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q

! p37
       elseif(fnam(1:3).eq.'p37') then
c 1=Hong Kong, 2=Taiwan
          if(iendpoint.eq.1) then
           write(level1(25:39),'(a15)') '116.00E:123.00W'
           icenter = 176
          elseif(iendpoint.eq.2) then
           write(level1(25:39),'(a15)') '120.50E:123.00W'
           icenter = 179
          elseif(iendpoint.eq.3) then
           write(level1(25:39),'(a15)') '202.00E:237.00E'
           icenter = 221
          endif

          write(55,'(a,a)') level1(1:59), levp37(1:45)
          write(65,'(a,a)') level1(1:59), levp37(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p37'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p37'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)

          if(iendpoint.eq.1) then
           write(55,'(a)')
     $     'define axis/x=116.0E:122.5W:.1/units=degrees ybot'
           write(65,'(a)')
     $     'define axis/x=116.0E:122.5W:.1/units=degrees ybot'
          elseif(iendpoint.eq.2) then
           write(55,'(a)')
     $     'define axis/x=120.5E:123.0W:.1/units=degrees ybot'
           write(65,'(a)')
     $     'define axis/x=120.5E:123.0W:.1/units=degrees ybot'
          elseif(iendpoint.eq.3) then
           write(55,'(a)')
     $     'define axis/x=202.15E:236.95E:.1/units=degrees ybot'
           write(65,'(a)')
     $     'define axis/x=202.15E:236.95E:.1/units=degrees ybot'
          endif

          write(topo1(13:13),'(a1)')'x'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)

          if(iendpoint.eq.1) then
           b1(1:41) = 'file/var=bathhk/skip=1/col=1216/grid=topo'
           b2(1:27) = ' "/data/xbt/p37/bathhk.grd"'
          write(55,'(a,a)')b1, b2
          write(65,'(a,a)')b1, b2
          write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhk'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhk'
          elseif(iendpoint.eq.2) then
           b1(1:41) = 'file/var=bathko/skip=1/col=1166/grid=topo'
           b2(1:27) = ' "/data/xbt/p37/bathko.grd"'
          write(55,'(a,a)')b1, b2
          write(65,'(a,a)')b1, b2
          write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathko'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathko'
          elseif(iendpoint.eq.3) then
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
          write(55,'(a)') axlonb
          write(65,'(a)') axlonb
          write(topo1(13:13),'(a1)')'x'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)
           b3(1:31) = ' "/data/xbt/p37/0811/bath1.grd" '
            b3(17:20) = fnam(4:7)
          write(55,'(a,a)')topofile, b3
          write(65,'(a,a)')topofile, b3
          write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
          write(55,'(a)')'label 203,-40,0,0,.2,Hawaii'
          write(65,'(a)')'label 203,-40,0,0,.2,Hawaii'
           write(55,'(a)')'label 235,-40,0,0,.20 San Francisco'
           write(65,'(a)')'label 235,-40,0,0,.20 San Francisco'
          ship(1:24) = 'label 221,980,0,0,.18, "'
          write(ship(7:9),'(i3)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q

          endif

          write(55,*)
          write(65,*)
          if(iendpoint.eq.1) then
           write(55,'(a)')'label 116,-40,0,0,.2,Hong Kong'
           write(65,'(a)')'label 116,-40,0,0,.2,Hong Kong'
          elseif(iendpoint.eq.2) then
           write(55,'(a)')'label 120,-40,0,0,.2,Taiwan'
           write(65,'(a)')'label 120,-40,0,0,.2,Taiwan'
          elseif(iendpoint.eq.3) then
           go to 366
          endif
          write(55,'(a)')'label 144,-40,0,0,.2,Guam'
          write(65,'(a)')'label 144,-40,0,0,.2,Guam'
          write(55,'(a)')'label 230,-40,0,0,.2,San Francisco'
          write(65,'(a)')'label 230,-40,0,0,.2,San Francisco'
          write(55,'(a)')'label 203,-40,0,0,.2,Honolulu'
          write(65,'(a)')'label 203,-40,0,0,.2,Honolulu'

          ship(1:24) = 'label 110,980,0,0,.18, "'
          write(ship(7:9),'(i3)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
366       continue
c p38
       elseif(fnam(1:3).eq.'p38') then
          write(level1(25:39),'(a15)') ' 21.50N: 61.00N'
          icenter = 41
          write(55,'(a,a)') level1(1:59), levp38(1:45)
          write(65,'(a,a)') level1(1:59), levp38(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(2,30,2,-3) DARK(10,30,10,-3)" p38'
          write(65,'(a,a)')overw(1:43),
     $                       '"(2,30,2,-3) DARK(10,30,10,-3)" p38'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
          write(55,'(a)')
     $     'define axis/y=21.3N:61.0N:.1/units=degrees ybot'
          write(65,'(a)')
     $     'define axis/y=21.3N:61.0N:.1/units=degrees ybot'
          write(55,'(a31)') topo1(1:31)
          write(65,'(a31)') topo1(1:31)
          b1(1:41) = 'file/var=bathhv/skip=1/col=398/grid=topo '
          b2(1:27) = ' "/data/xbt/p38/bathhv.grd"'
          write(55,'(a40,a27)')b1, b2
          write(65,'(a40,a27)')b1, b2
          write(55,'(a63)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhv'
          write(65,'(a63)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhv'
          write(55,*)
          write(65,*)
          write(55,'(a)')'label 20,-30,-1,0,.2,Honolulu'
          write(65,'(a)')'label 20,-30,-1,0,.2,Honolulu'
          write(55,'(a)')'label 61,-30,1,0,.2,Valdez'
          write(65,'(a)')'label 61,-30,1,0,.2,Valdez'
          ship(1:23) = 'label   ,980,0,0,.19, "'
          write(ship(7:8),'(i2)') icenter
          write(55,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship(1:23), ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
! p40
        elseif(fnam(1:3).eq.'p40') then
            write(level1(25:39),'(a15)') '139.75E:202.05E'
            icenter = 171
           write(55,'(a,a)') level1(1:59), levp40(1:45)
           write(65,'(a,a)') level1(1:59), levp40(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p40'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p40'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a)') tc(1:54)
           write(65,'(a)') tc(1:54)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
           write(55,'(a)') axlonb
           write(65,'(a)') axlonb
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
            b3(1:31) = ' "/data/xbt/p40/0811/bath1.grd"'
            b3(17:20) = fnam(4:7)
           write(55,'(a,a)')topofile, b3
           write(65,'(a,a)')topofile, b3
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
           write(55,'(a)')'label 201,-40,0,0,.2,Hawaii'
           write(65,'(a)')'label 201,-40,0,0,.2,Hawaii'
           write(55,'(a)')'label 140,-40,0,0,.20 Yokohama'
           write(65,'(a)')'label 140,-40,0,0,.20 Yokohama'
           ship(1:24) = 'label 110,980,0,0,.18, "'
           write(ship(7:9),'(i3)') icenter
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
! p44
! 16jun2014 to do , fix all p44:
        elseif(fnam(1:3).eq.'p44') then
            write(level1(25:39),'(a15)') '120.25E:145.55E'
            icenter = 171
           levp40(44:44)='4'
           write(55,'(a,a)') level1(1:59), levp40(1:45)
           write(65,'(a,a)') level1(1:59), levp40(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

           write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p44'
           write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,-3) DARK(10,30,10,-3)" p44'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
           write(55,*)
           write(65,*)
           write(55,'(a)') tc(1:54)
           write(65,'(a)') tc(1:54)
           write(55,'(a)') tc1(1:35)
           write(65,'(a)') tc1(1:35)
           write(55,*)
           write(65,*)
           write(axlonb(15:20),'(f6.2)') abs(xleft)
           write(axlonb(21:21),'(a1)') ahem(1:1)
           write(axlonb(23:28),'(f6.2)') abs(xright)
           write(axlonb(29:29),'(a1)') ahem(1:1)
           write(55,'(a)') axlonb
           write(65,'(a)') axlonb
           write(topo1(13:13),'(a1)')'x'
           write(55,'(a)') topo1(1:31)
           write(65,'(a)') topo1(1:31)
            b3(1:31) = ' "/data/xbt/p44/0811/bath1.grd"'
            b3(17:20) = fnam(4:7)
           write(55,'(a,a)')topofile, b3
           write(65,'(a,a)')topofile, b3
           write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
           write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bath'
           write(55,'(a)')'label 120,-40,0,0,.20 Taiwan'
           write(65,'(a)')'label 120,-40,0,0,.20 Taiwan'
           write(55,'(a)')'label 127.3,-40,0,0,.20 Naha'
           write(65,'(a)')'label 127.3,-40,0,0,.20 Naha'
           write(55,'(a)')'label 145.3,-40,0,0,.2,Guam'
           write(65,'(a)')'label 145.3,-40,0,0,.2,Guam'
           ship(1:24) = 'label 133,980,0,0,.18, "'
           write(ship(7:9),'(i3)') icenter
           write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
           write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1),
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q

! p50
       elseif(fnam(1:3).eq.'p50') then

! iendpoint =  1=valpariso, 2=callao
! istartpoint =  1=Auckland, 2=Lyttelton
          if(iendpoint.eq.1) then
           if(istartpoint.eq.1) then
            write(level1(25:39),'(a15)') '175.60E: 71.60W'
           elseif(istartpoint.eq.2) then
            write(level1(25:39),'(a15)') '173.40E: 71.60W'
           endif
          elseif(iendpoint.eq.2) then
           if(istartpoint.eq.1) then
            write(level1(25:39),'(a15)') '175.60E: 77.65W'
           elseif(istartpoint.eq.2) then
            write(level1(25:39),'(a15)') '173.40E: 77.65W'
           endif
          endif

          write(55,'(a,a)') level1(1:59), levp50(1:45)
          write(65,'(a,a)') level1(1:59), levp50(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')over(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p50'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p50'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
c bottom topo:
          if(iendpoint.eq.1) then
           if(istartpoint.eq.1) then
c auckland-valpariso
            write(55,'(a)')
     $       'define axis/x=175.60E:288.40E:.1/units=degrees ybot'
            write(65,'(a)')
     $       'define axis/x=175.60E:288.40E:.1/units=degrees ybot'
            write(topo1(13:13),'(a1)')'x'
            write(55,'(a)') topo1(1:31)
            write(65,'(a)') topo1(1:31)
            b1(1:41) = 'file/var=bathva/skip=1/col=1129/grid=topo'
            b2(1:27) = ' "/data/xbt/p50/bathva.grd"'
            write(55,'(a,a)')b1, b2
            write(65,'(a,a)')b1, b2
            write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathva'
            write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathva'
           elseif(istartpoint.eq.2) then
c lyttelton-valpariso
            write(55,'(a)')
     $       'define axis/x=173.40E:288.40E:.1/units=degrees ybot'
            write(65,'(a)')
     $       'define axis/x=173.40E:288.40E:.1/units=degrees ybot'
            write(topo1(13:13),'(a1)')'x'
            write(55,'(a)') topo1(1:31)
            write(65,'(a)') topo1(1:31)
            b1(1:41) = 'file/var=bathvl/skip=1/col=1151/grid=topo'
            b2(1:27) = ' "/data/xbt/p50/bathvl.grd"'
            write(55,'(a,a)')b1, b2
            write(65,'(a,a)')b1, b2
            write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathvl'
            write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathvl'
           endif

          elseif(iendpoint.eq.2) then
           if(istartpoint.eq.1) then
c auckland-callao
            write(55,'(a)')
     $       'define axis/x=176.0E:282.4E:.1/units=degrees ybot'
            write(65,'(a)')
     $       'define axis/x=176.0E:282.4E:.1/units=degrees ybot'
            write(topo1(13:13),'(a1)')'x'
            write(55,'(a)') topo1(1:31)
            write(65,'(a)') topo1(1:31)
            b1(1:41) = 'file/var=bathca/skip=1/col=1065/grid=topo'
            b2(1:27) = ' "/data/xbt/p50/bathca.grd"'
            write(55,'(a,a)')b1, b2
            write(65,'(a,a)')b1, b2
            write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathca'
            write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathca'
           elseif(istartpoint.eq.2) then
c lyttelton-callao (as of 0103 not happened yet!)
            stop ' whoa - have not made this bottom topo file yet!'
           endif
          endif

          write(55,*)
          write(65,*)
          if(istartpoint.eq.1) then
           write(55,'(a)')'label 175,-30,0,0,.2,Auckland'
           write(65,'(a)')'label 175,-30,0,0,.2,Auckland'
          elseif(istartpoint.eq.2) then
           write(55,'(a)')'label 175,-30,0,0,.2,Lyttelton'
           write(65,'(a)')'label 175,-30,0,0,.2,Lyttelton'
          endif

          if(iendpoint.eq.1) then
           write(55,'(a)')'label 281,-30,0,0,.2,Valparaiso'
           write(65,'(a)')'label 281,-30,0,0,.2,Valparaiso'
          elseif(iendpoint.eq.2) then
           write(55,'(a)')'label 281,-30,0,0,.2,Callao    '
           write(65,'(a)')'label 281,-30,0,0,.2,Callao    '
          endif

          ship(1:24) = 'label 175,980,-1,0,.2, "'
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
c p81
       elseif(fnam(1:3).eq.'p81') then
c istartpoint=1=Hiroshima px25
c istartpoint=2=Hachinohe px25
c istartpoint=3=Honolulu px81
c istartpoint=4=stop at Honolulu follows px25
          if(istartpoint.eq.1) then
           write(level1(25:39),'(a15)') ' 37.00S: 33.60N'
            icenter = -2
          elseif(istartpoint.eq.2) then
           write(level1(25:39),'(a15)') ' 37.00S: 40.60N'
            icenter = 2
          elseif(istartpoint.eq.3) then
           write(level1(25:39),'(a15)') ' 37.00S: 21.00N'
            icenter = -8
          elseif(istartpoint.eq.4) then
           write(level1(25:39),'(a15)') ' 37.00S: 21.00N'
            icenter = -8
          endif
          write(55,'(a,a)') level1(1:59), levp81(1:45)
          write(65,'(a,a)') level1(1:59), levp81(1:45)
           write(55,'(a)')shakey
           write(65,'(a)')shakey
           write(55,'(a)')ps
           write(65,'(a)')ps

          write(55,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p81'
          write(65,'(a,a)')overw(1:43),
     $                       '"(4,30,2,1) DARK(10,30,10,1)" p81'
           write(55,'(a)')conset
           write(65,'(a)')conset
           write(55,'(a)')pcn
           write(65,'(a)')pcn
          write(55,*)
          write(65,*)
          write(55,'(a)') tc(1:54)
          write(65,'(a)') tc(1:54)
          write(55,'(a)') tc1(1:35)
          write(65,'(a)') tc1(1:35)
          write(55,*)
          write(65,*)
          write(55,'(a)')
     $     'define axis/y=37.00S:21.0N:.1/units=degrees ybot'
          write(65,'(a)')
     $     'define axis/y=37.00S:21.0N:.1/units=degrees ybot'
          write(topo1(13:13),'(a1)')'y'
          write(55,'(a)') topo1(1:31)
          write(65,'(a)') topo1(1:31)
          b1(1:41) = 'file/var=bathhc/skip=1/col=581/grid=topo '
          b2(1:27) = ' "/data/xbt/p81/bathhc.grd"'
          write(55,'(a,a)')b1, b2
          write(65,'(a,a)')b1, b2
          write(55,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhc'
          write(65,'(a)')
     $ 'shade/nolab/nokey/over/palette=black/lev=(9,10000,10000) bathhc'
          write(55,*)
          write(65,*)
c in web one - blank out near Chile!
          write(65,'(a)') chileblank1
          write(65,'(a)') chileblank2
          write(65,*)

          write(55,'(a)')'label -37,-30,0,0,.2,Coronel'
          write(65,'(a)')'label -37,-30,0,0,.2,Coronel'

          if(istartpoint.eq.1) then
           write(55,'(a)')'label  33,-30,0,0,.2,Hiroshima'
           write(65,'(a)')'label  33,-30,0,0,.2,Hiroshima'
          elseif(istartpoint.eq.2) then
           write(55,'(a)')'label  38,-30,0,0,.2,Hachinohe'
           write(65,'(a)')'label  38,-30,0,0,.2,Hachinohe'
          elseif(istartpoint.eq.3) then
           write(55,'(a)')'label  20,-30,0,0,.2,Honolulu'
           write(65,'(a)')'label  20,-30,0,0,.2,Honolulu'
          elseif(istartpoint.eq.4) then
           write(55,'(a)')'label  20,-30,0,0,.2,"21 N"'
           write(65,'(a)')'label  20,-30,0,0,.2,"21 N"'
          endif

          ship(1:24) = 'label    ,980,0,0,.19, "'
           if(icenter.le.-1.and.icenter.ge.-9) then
                   write(ship(8:9),'(i2)') icenter
           elseif(icenter.ge.0.and.icenter.le.9) then
                   write(ship(9:9),'(i1)') icenter
           endif
          write(55,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
          write(65,'(a,a,a,a,a,a,a)') ship, ship2(1:l1), 
     $              shipname(1:l2), adate(1:23),', ',
     $              ngoodsta(1:14),q
       endif
       write(55,*)
       write(65,*)
       close(55)
       close(65)
       return
       end

