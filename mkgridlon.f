       program mkgridlon
! This is a custom file, which makes a set number based on the number
! of points desired in the output. This is expected to be run ONLY on
! transects that lon changes, with lat a constant.
! 07aug2025 BRZENSKI
!
!  9aug2019 LL - extend p09 from 48.15 to 48.45...
! 23jun2016 - need to rerun p06????c.10 files to get a matching "p09"
!  length of track...
! 18jan2013 add atlantic 
! 15mar2012 LL - read p09????x.10 files for cruise lat,lon, then
! try to create longitude to match p09 gridded latitude points
       parameter(nxpts=600)
       parameter(ngptsmax=859)
       character fnam*11, output*14
       real xlat(nxpts), xlon(nxpts)
       real glat(ngptsmax), glon(ngptsmax)

       data fnam/'p099105a.10'/
       data output/'latlongrid.txt'/
!
       write(*,*)' Enter .10 filename : (ie, p099105a) (8 chars!)'
       read(5,'(a8)') fnam(1:8)
       write(*,*) 'fnam=', fnam(1:8)
! write 'a' or 'b' to char(10:10) in output (latlongria.txt or latlongrib.txt)
       output(10:10) = fnam(8:8)
! 
       if(fnam(1:3).eq.'p09'.or.fnam(1:3).eq.'p13') then
! set up grid latitude points: entire p09 track Tauranga-Seattle
! not sure about 855:
! East Cape is further south than this.. so this does not work for those...
          ngpts = 859    ! go to 48.45
! was to 48.15:          ngpts = 856
          gl1 = -37.35
       elseif(fnam(1:3).eq.'p06') then
          write(*,*)'do you want the short or long version?'
          write(*,*)'1 = p06 track only'
          write(*,*)'2 = p09/p13 track '
          read(5,'(i1)') itrack
          if(itrack.eq.1) then
             ngpts = 193
             gl1 = -37.35
          else
             ngpts = 859    ! go to 48.45
! was to 48.15:             ngpts = 856
             gl1 = -37.35
          endif
       elseif(fnam(1:3).eq.'p05') then
          ngpts = 616
          gl1 = -26.55
       elseif(fnam(1:3).eq.'p38') then
          ngpts = 397
          gl1 = 21.35
       elseif(fnam(1:3).eq.'a08') then
          ngpts = 794
          gl1 = -33.75
       elseif(fnam(1:3).eq.'a10') then
          ngpts = 221
          gl1 = 18.45
       else
          stop 'Add this line to mkgridlon.f or use mkgridlat.f '
       endif
!
       open(22,file=output,status='unknown',form='formatted')

! create latitude grid: .1 deg grid matches tem/sal files:
       write(33,*)'glat='
       do 3 i = 1, ngpts
          glat(i) = gl1 + (i-1)*0.10
          write(33,*) glat(i)
3     continue
!

        write(*,*)' opening  ',fnam
        open(7,file=fnam,status='old')
        read(7,*)nsta
        write(33,*)'nsta=',nsta
        if(nsta.gt.nxpts) stop 'nsta gt npts'
! read .10 file to find begining lat or lon.  Note if orient=lon then putting
! longitude values into xlat,blat,elat (confusing!):
        do i=1,nxpts
           read(7,520,end=712)xlat(i),xlon(i)
           write(33,*)'xlat,xlon',xlat(i),xlon(i)
520        format(2f9.3)
           do j=1,8
              read(7,*)
           end do
        end do
712     continue
        nsta = i-1
!
! check to see whether section is north-south or south-north
! nssect = -1 means that section is north-south 
       if (xlat(1).gt.xlat(nsta)) then
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
!
! loop through stations to find the 2 that surround the glat, then interp to 
! get the glon:
       do 20 kg = 1, ngpts
        ifoundlo = 0
        write(33,*)'look for glat(kg)=',kg,glat(kg)
        do 30 k = nbeg, nend, inc
          write(33,*)'check xlat(k)',k,xlat(k)
          if(xlat(k).eq.glat(kg)) then
             glon(kg) = xlon(k)
             go to 18
          elseif(xlat(k).lt.glat(kg)) then
             xlatlo = xlat(k)
             xlonlo = xlon(k)
             ifoundlo = 1
             write(33,*)'found lo', xlatlo,xlonlo
          elseif(xlat(k).gt.glat(kg)) then
             write(33,*)'xlat(k)>glat(kg)'
             if(ifoundlo.eq.0) then
                glon(kg) = 999.0
                go to 18
             else
                xlathi = xlat(k)
                xlonhi = xlon(k)
                write(33,*)'found hi'
                write(33,*) xlatlo,glat(kg),xlathi
                write(33,*) xlonlo,'       ' ,xlonhi
! linear interp:
                frac = (glat(kg)-xlatlo)/(xlathi-xlatlo)
                glon(kg) = xlonlo + (xlonhi-xlonlo)*frac
                go to 18
             endif
          else
! if we are here then not enough points in p34xxxx.dat 
             glon(kg) = 999.0
             go to 18
          endif
! if we are here then not enough points in p34xxxx.dat 
          if(k.eq.nend) then
             glon(kg) = 999.0
             go to 18
          endif
30      continue

18      continue
        write(33,*) 'grid=',glat(kg),glon(kg)
        write(22,'(2f9.3)') glat(kg),glon(kg)
20     continue
       close(22)
      stop
      end

