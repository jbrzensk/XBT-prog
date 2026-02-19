       program mkgridbath
! 16may2012 LL add a 4th column of the shallowest depth of the
!   2 surrounding XBT's used for the tem/sal/del grid point
! 10may2012 LL
! read each cruise latlongrid.txt (mkgridlat.f/mkgridlon.f) and
! bath1.dat (find-e-dep.f + mkcruisebath.f)
! to create individual cruise lat, lon grid with corresponding
! grid bath (edep + SnS) obviously SnS is only fair estimate, but HB's
! are quite goo.
! ngpts = number of grid points
       parameter(ngptsmax=1212)
! nposmax = number of actual drop positions 
       parameter(nposmax=999)
! p37=1212, p34=226, p31=250)
       character latlonin*14
       character vlatlonin*14
       character bathin*9
       character bathinnew*13
       character output*18
       character voutput*18
       character*3 latlon
       character*8 fnam
       real glat(ngptsmax), glon(ngptsmax), gbath(ngptsmax)
       real vlat(ngptsmax), vlon(ngptsmax), vbath(ngptsmax)
       real xlon(nposmax),xlat(nposmax),bath(nposmax),ebath(nposmax)

       data fnam     /'p319004a'/
       data latlonin /'latlongrid.txt'/
       data vlatlonin/'latlonvgra.txt'/
       data bathin   /'bath1.dat'/
       data bathinnew/'p210704a-bath'/
       data output   /'latlonbathgrid.txt'/
       data voutput  /'latlonbathvgra.txt'/
!                      123456789012345678
       write(*,*)'Enter cruise name (p349109a)'
       read(5,'(a)') fnam(1:8)
!   
       if(fnam(1:3).eq.'p31') then
          ngpts = 250
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p34') then
          ngpts = 226
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p50') then
          ngpts = 1150
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p37') then
          ngpts = 1212
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'s37') then
          ngpts = 395
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p38') then
          ngpts = 397
          latlon = 'lat'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p40') then
          ngpts = 625
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p44') then
          ngpts = 254
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p05') then
! this one is a pain, since only the first cruise starts at -26.55, the rest at -26.15
          ngpts = 616
          latlon = 'lat'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p37') then
          ngpts = 1212
          latlon = 'lon'
! 7may2012 LL mods for i15/i21 dur-maur only, obviously name is screwy...
       elseif(fnam(2:3).eq.'21'.or.fnam(2:3).eq.'15') then
          ngpts = 1121
          latlon = 'lon'
!          bathinnew(1:8) = fnam(1:8)
          bathin(5:5) = fnam(8:8)   ! for i21 and i15, batha.dat is generated
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p06') then
          ngpts = 193
          latlon = 'lat'
          bathin(5:5) = fnam(8:8)
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
!          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'p09'.or.fnam(1:3).eq.'p13') then
! 9aug2019 increase          ngpts = 856
          ngpts = 859
          latlon = 'lat'
          bathin(5:5) = fnam(8:8)
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'a07') then
          ngpts = 805
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'a08') then
          ngpts = 794
          latlon = 'lat'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'a10') then
          ngpts = 221
          latlon = 'lat'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'a18') then
          ngpts = 730
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       elseif(fnam(1:3).eq.'a97') then
          ngpts = 135
          latlon = 'lon'
          output(14:14) = fnam(8:8)
          voutput(14:14) = fnam(8:8)
          latlonin(10:10) = fnam(8:8)
          vlatlonin(10:10) = fnam(8:8)
       else
          stop ' add this line to mkgridbath.f '
       endif
       write(33,*)'latlon=',latlon
! open and read local cruise bath1.dat:
! recall the order of bath1.dat is like stations.dat, NOT necessarily
! same direction at latlongrid.txt (W->E and S->N)
! xpos is long, ypos is lat
       if(fnam(2:3).eq.'15'.or.fnam(2:3).eq.'21') then
       open(30,file=bathin,status='old',form='formatted',err=700) ! bathin, not bathinnew, since for i15/i21 we are using batha.dat which is generated by mkcruisebath.f
       else
       open(30,file=bathin,status='old',form='formatted',err=700)
       endif
! skip first line of text
       read(30,*)
       write(33,*)'reading ', bathin
       do 10 k = 1, nposmax
          read(30,504,end=11)xlon(k),xlat(k),ebath(k),bath(k)
          write(33,*) xlon(k),xlat(k),ebath(k),bath(k)
504    format(2f8.3,18x,f8.0,7x,f8.0)
! original: 504    format(2f8.3,f8.0,1x,f8.0,1x,f8.0,1x,a5,1x,f8.0)
10     continue
11     continue
       close(30)
! determine how to search the bath1.dat data, forward or backward:
       nbathtot = k - 1
       if(latlon.eq.'lon') then
          if(xlon(1).gt.xlon(10)) then ! flip
             nbeg = nbathtot
             nend = 1
             inc = -1
          else
             nbeg = 1
             nend = nbathtot
             inc = 1
          endif
       elseif(latlon.eq.'lat') then
          if(xlat(1).gt.xlat(10)) then
             nbeg = nbathtot
             nend = 1
             inc = -1
          else
             nbeg = 1
             nend = nbathtot
             inc = 1
          endif
       endif
       write(33,*)'nbeg,nend,inc=',nbeg, nend, inc
!
       write(33,*)'reading ', latlonin
       open(20,file=latlonin,status='old',form='formatted')
       open(22,file=output,status='unknown',form='formatted')
! read each latlongrid.txt point and loop through bath1.dat data
! to find surrounding lat OR lon (dependent on latlon!) 
!   and interp to get the grid pt bath value
       do 20 kg = 1, ngpts
        read(20,'(2f9.3)') glat(kg),glon(kg)
        write(33,*) glat(kg),glon(kg)
        if(glat(kg).eq.999.00.or.glon(kg).eq.999.00) then
           gbath(kg) = 999.00
           write(22,567) glat(kg),glon(kg),gbath(kg), 999.0,999.0
           write(33,*) 'gbath(kg)=',gbath(kg), kg
           go to 20
        endif
        ifoundlo = 0
!
        if(latlon.eq.'lon') then
        write(33,*)'look for glon=',glon(kg)
        do 30 k = nbeg, nend, inc
          if(xlon(k).eq.glon(kg)) then
             gbath(kg) = bath(k)
             ebathlo = ebath(k)
             ebathhi = ebath(k)
             write(33,*) '==', k,bath(k),ebath(k)
             go to 18
          elseif(xlon(k).lt.glon(kg)) then
             write(33,*)'lt', xlat(k), xlon(k)
             xlonlo = xlon(k)
             xbathlo = bath(k)
             ebathlo = ebath(k)
             ifoundlo = 1
             write(33,*)'found xlonlo', xlonlo,' k=',k
          elseif(xlon(k).gt.glon(kg)) then
             write(33,*)'gt', xlat(k), xlon(k)
             if(ifoundlo.eq.0) then
                gbath(kg) = 999.0
                ebathlo = 999.0
                ebathhi = 999.0
                write(33,*) 'all 999.0'
                go to 18
             else
                xlonhi = xlon(k)
                xbathhi = bath(k)
                ebathhi = ebath(k)
                write(33,*)'found xlonhi',xlonhi,' k=',k
                write(33,*) xbathlo,'      ',xbathhi
                write(33,*) xlonlo,glon(kg) ,xlonhi
! linear interp:
                frac = (glon(kg)-xlonlo)/(xlonhi-xlonlo)
                gbath(kg) = xbathlo + (xbathhi-xbathlo)*frac
                go to 18
             endif
          endif
! if we are here then not enough points in p34xxxx.dat 
          write(33,*) 'not enuf pts'
          if(k.eq.nend) then
             glat(kg) = 999.0
             go to 18
          endif
30      continue
        else ! latlon=lat
        write(33,*)'look for glat=',glat(kg)
        do 31 k = nbeg, nend, inc
          if(xlat(k).eq.glat(kg)) then
             gbath(kg) = bath(k)
             ebathlo = ebath(k)
             ebathhi = ebath(k)
             go to 18
          elseif(xlat(k).lt.glat(kg)) then
             write(33,*)xlat(k), xlon(k)
             xlatlo = xlat(k)
             xbathlo = bath(k)
             ebathlo = ebath(k)
             ifoundlo = 1
             write(33,*)'found xlatlo', xlatlo,' k=',k
          elseif(xlat(k).gt.glat(kg)) then
             if(ifoundlo.eq.0) then
                bath(kg) = 999.0
                ebathlo = 999.0
                ebathhi = 999.0
                go to 18
             else
                xlathi = xlat(k)
                xbathhi = bath(k)
                ebathhi = ebath(k)
                write(33,*)'found xlathi',xlathi,' k=',k
                write(33,*) xbathlo,'      ',xbathhi
                write(33,*) xlatlo,glat(kg) ,xlathi
! linear interp:
                frac = (glat(kg)-xlatlo)/(xlathi-xlatlo)
                gbath(kg) = xbathlo + (xbathhi-xbathlo)*frac
                go to 18
             endif
          endif
! if we are here then not enough points in p34xxxx.dat 
          if(k.eq.nend) then
             glat(kg) = 999.0
             ebathlo = 999.0
             ebathhi = 999.0
             go to 18
          endif
31     continue
       endif

18      continue
        write(33,*) 'gbath(kg)=',gbath(kg), kg
        write(22,567) glat(kg),glon(kg),gbath(kg),ebathlo, ebathhi
20     continue
567    format(2f9.3,3f7.0)
       close(20)
       close(22)
! now create vel gridded bath:
       ngpts1 = ngpts-1
! read old latlonvgra.txt:
       open(30,file=vlatlonin,status='old',form='formatted',err=702)
! output is latlonbathvgra.txt
       open(32,file=voutput,status='unknown',form='formatted')
       do 85 i = 1, ngpts1
          read(30,'(2f9.3)',err=702) vlat(i),vlon(i)
          if (vlat(i).eq.999.0.or.vlon(i).eq.999.0) then
             vbath(i) = 999.0
          else
             if(gbath(i).eq.999.0.or.gbath(i+1).eq.999.0) then
                vbath(i) = 999.0
!                stop 'you have a problem'
             else
                vbath(i) = (gbath(i)+gbath(i+1))/2.0
             endif
          endif
          write(32,'(2f9.3,f7.0)') vlat(i), vlon(i), vbath(i)
85     continue
       close(30)
       close(32)

       go to 701
700    write(*,*)'no bath1.dat, run find-e-dep.x + mkcruisebath.x'
       go to 701
702    write(*,*)'no latlonvgrX, run mktrackvel'
701    continue
      stop
      end

