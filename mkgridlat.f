       program mkgridlat
! This expects only transects that need griddd lons, with cons
! tant lats.
! 07aug2025 BRZENSKI
! 18jan2013 add atlantic
! this one modified to create lats for gridded longs! (p34/p31)
! 15mar2012 LL - read p09????x.10 files for cruise lat,lon, then
! try to create longitude to match p09 gridded latitude points
! only doing for p09 (suva to 5N cruises) so some others will get
! skipped
! nxpts = number of points (stations) in .10 file
       parameter(nxpts=600)
! ngpts = number of grid points
       parameter(ngptsmax=1212)
! p37=1212, p34=226, p31=250
       character fnam*11, output*14, logfile*14
       real xlat(nxpts), xlon(nxpts)
       real glat(ngptsmax), glon(ngptsmax)

       data fnam/'p319105a.10'/
       data output/'latlongrid.txt'/
       data logfile/'latlongrid.log'/
       write(*,*)' Enter .10 filename : (ie, p099105a) (8 chars!)'
       read(5,'(a8)') fnam(1:8)
       write(*,*) 'fnam=', fnam(1:8)
       output(10:10) = fnam(8:8)
!   
       if(fnam(1:3).eq.'p31') then
          ngpts = 250
          gl1 = 153.45
       elseif(fnam(1:3).eq.'p34') then
          ngpts = 226
          gl1 = 151.35
       elseif(fnam(1:3).eq.'p37') then
          ngpts = 1212
          gl1 = 115.95
       elseif(fnam(1:3).eq.'p50') then
          ngpts = 1150
          gl1 = 173.45
       elseif(fnam(1:3).eq.'s37') then
          ngpts = 395
          gl1 = 202.25
       elseif(fnam(1:3).eq.'p40') then
          ngpts = 625
          gl1 = 139.65
       elseif(fnam(1:3).eq.'p44') then
          ngpts = 254
          gl1 = 120.25
! 8jun2012 no more, do whole thing-7may2012 LL mods for i15/i21 dur-maur only, obviously name is screwy...
       elseif(fnam(2:3).eq.'15'.or.fnam(2:3).eq.'21') then
          ngpts = 1121
          gl1 = 31.15 
       elseif(fnam(1:3).eq.'a07') then
          ngpts = 805
          gl1 = 279.95
       elseif(fnam(1:3).eq.'a18') then
          ngpts = 730
          gl1 = 307.05
       elseif(fnam(1:3).eq.'a97') then
          ngpts = 135
          gl1 = 317.25
       else
          stop 'Add this line to mkgridlat.f or use mkgridlon.f '
       endif

       open(22,file=output,status='unknown',form='formatted')
! Formally open the logfile, which is all the 33 writes
       open(33,file=logfile,status='unknown',form='formatted')
! create longitude .1 deg grid (matches .tem/sal files)
       write(33,*)'glon='
       do 3 i = 1, ngpts
          glon(i) = gl1 + (i-1)*0.10
          write(33,*) glon(i)
3     continue

        write(*,*)' opening  ',fnam
        open(7,file=fnam,status='old')
        read(7,*)nsta
        write(33,*)'nsta=',nsta
        if(nsta.gt.nxpts) stop 'nsta gt npts'
        do 710 i=1,nxpts
           read(7,520,end=712)xlat(i),xlon(i)
           write(33,520)xlat(i),xlon(i)
520        format(2f9.3)
! skip the data in the .10 file:
        do 710 j=1,8
710     read(7,*)
712     continue
        nsta = i-1
        write(33,*)'new nsta=',nsta
!       write(33,*) 'aft 712',xlat(nsta), xlon(nsta)
!
! check to see whether section is north-south or south-north
! nssect = -1 means that section is north-south 
!       if (xlat(1).gt.xlat(nsta)) then
! for long, check E-W or W-E
! nssect = -1 -> E-W 
       if (xlon(1).gt.xlon(nsta)) then
        nssect = -1
        nbeg = nsta
        nend = 1
        inc = -1
       else
        nssect = 1
        nbeg = 1
        nend = nsta
        inc = 1
       endif
       write(33,*)'nbeg=',nbeg,' nend=',nend,' inc=',inc
       write(33,*) xlat(nsta), xlon(nsta)
!
! loop through stations to find the 2 that surround the glat, then interp to 
! get the glon:
       do 20 kg = 1, ngpts
        ifoundlo = 0
        write(33,*)'look for glon=',glon(kg)
        do 30 k = nbeg, nend, inc
          if(xlon(k).eq.glon(kg)) then
             glat(kg) = xlat(k)
             go to 18
          elseif(xlon(k).lt.glon(kg)) then
             write(33,*)xlat(k), xlon(k)
             xlonlo = xlon(k)
             xlatlo = xlat(k)
             ifoundlo = 1
             write(33,*)'found lo', xlatlo,xlonlo,' k=',k
          elseif(xlon(k).gt.glon(kg)) then
             if(ifoundlo.eq.0) then
                glat(kg) = 999.0
                go to 18
             else
                xlathi = xlat(k)
                xlonhi = xlon(k)
                write(33,*)'found hi',' k=',k
                write(33,*) xlatlo,'      ',xlathi
                write(33,*) xlonlo,glon(kg) ,xlonhi
! linear interp:
                frac = (glon(kg)-xlonlo)/(xlonhi-xlonlo)
                glat(kg) = xlatlo + (xlathi-xlatlo)*frac
                go to 18
             endif
          endif
! if we are here then not enough points in p34xxxx.dat 
          if(k.eq.nend) then
             glat(kg) = 999.0
             go to 18
          endif

30      continue
18      continue
!        write(33,*) 'grid=',glat(kg),glon(kg)
        write(22,'(2f9.3)') glat(kg),glon(kg)
20     continue
       close(22)
      stop
      end

