      program mktrackvel
! 6apr2012 LL original from /data/xbt/netcdf to read p30list.trk
! and create p30list.vel.trk - modify to read each cruises
! latlongrid.txt (tem/sal lat,lon grid) to create latlonvgrd.txt
! which ought to be the middie poitns for the vel grid.

! 28mar2012 LL try p34....
! 21mar2012 LL - read p09list.trk (tem/sal lat, lon) to
! create vel lat,lon (middie pt)
! 
! npts for p30 track        
!       parameter(npts=250)
! npts for p34 track        
!       parameter(npts=215)
! just make npts big
       parameter(npts=1212)
!
       real glat(npts),glon(npts)
       real glatave(npts)
       real glonave(npts)
       integer nvals(npts)
!
       character*3 orient
       character*1 char
       character*8 fnam
       character*14 input, output
       data input /'latlongrid.txt'/ 
       data output/'latlonvgrd.txt'/ 
       data fnam/'p099105a'/
!
       write(*,*)' Enter .10 filename : (ie, p099105a) (8 chars!)'
       read(5,'(a8)') fnam(1:8)
       write(*,*) 'fnam=', fnam(1:8)
       input(10:10) = fnam(8:8)
       output(10:10) = fnam(8:8)

       do 1 i = 1, npts
       glatave(i) = 0.0
1      glonave(i) = 0.0

! is this lat on lon based?
       if(fnam(1:3).eq.'p31') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p34') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p37') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p38') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'s37') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p40') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p44') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p50') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p09') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'p13') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'p05') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'a07') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'a08') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'a10') then
          orient = 'lat'
       elseif(fnam(1:3).eq.'a18') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'a97') then
          orient = 'lon'
       elseif(fnam(2:3).eq.'15') then
          orient = 'lon'
       elseif(fnam(2:3).eq.'21') then
          orient = 'lon'
       elseif(fnam(1:3).eq.'p06') then
! 23may2012 LL comment out since pulling this info in from a/b/c.10 file
! p06loop tricky, a=Auckland-Noumea=lon?, b=Noumea-Suva=lon, c=Auck-Suva=lat
!          write(*,*)'which section? '
!          write(*,*)'a = A-N = lon? '
!          write(*,*)'b = N-S = lon  '
!          write(*,*)'c = A-S = lat  '
!          read(5,'(a1)') char
          if(fnam(8:8).eq.'a') then
             orient = 'lon'
          elseif(fnam(8:8).eq.'b') then
             orient = 'lon'
          elseif(fnam(8:8).eq.'c') then
             orient = 'lat'
          endif
       else
          stop 'fix orient'
       endif
      
       open(30,file=input,status='old',form='formatted')
       open(31,file=output,status='unknown',form='formatted')
!
       do 80 j = 1, npts
          read(30,'(2f9.3)',end=81) glat(j), glon(j)
80     continue
81     ipts = j - 1
       close(10)
!
! latitude based;
       if(orient.eq.'lat') then
          do 260 j = 1, ipts-1
             glatave(j) = glat(j)+0.05
!! linear interp:
             if(glon(j).eq.999.000.or.glon(j+1).eq.999.000) then
                glonave(j) = 999.000
             else
                frac = (glatave(j)-glat(j))/(glat(j+1)-glat(j))
                glonave(j) = glon(j) + (glon(j+1)-glon(j))*frac
             endif
             write(31,'(2f9.3)') glatave(j), glonave(j)
260       continue
       elseif(orient.eq.'lon') then
! longitude:
          do 270 j = 1, ipts-1
             glonave(j) = glon(j)+0.05
! linear interp:
             if(glat(j).eq.999.000.or.glat(j+1).eq.999.000) then
                glatave(j) = 999.000
             else
                frac = (glonave(j)-glon(j))/(glon(j+1)-glon(j))
                glatave(j) = glat(j) + (glat(j+1)-glat(j))*frac
             endif
             write(31,'(2f9.3)') glatave(j), glonave(j)
270       continue
       endif ! orient

       close(30)
       close(31)
       stop
       end

