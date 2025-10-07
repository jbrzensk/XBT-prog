program mkcruisebath
  implicit none
  
  ! Constants
  integer, parameter :: nblonmax = 7400
  integer, parameter :: nblatmax = 5700
  integer, parameter :: nposmax = 999
  real, parameter :: deg2rad = 0.0174444
  
  ! Arrays
  real, dimension(nblonmax) :: snslon, snslon2
  real, dimension(nblatmax) :: snslat, snslat2
  real, dimension(nblonmax, nblatmax) :: snsbath, snsbath2
  real, dimension(nposmax) :: ypos, xpos, bath, bathave, edep
  real, dimension(4) :: sns
  integer, dimension(100) :: it
  integer, dimension(400) :: idn
  
  ! Character variables
  character(len=8) :: cr
  character(len=5) :: lcode
  character(len=80) :: cruise, edepfile, edepfilenew
  character(len=80) :: bathfile, bathfilenew, ofil
  character(len=80) :: bathname, bathname2
  character(len=4) :: c
  character(len=3) :: dropno
  character(len=1) :: atrack
  character(len=1) :: arange

  ! Variables
  integer :: nblat, nblon, nblat2, nblon2, iaddp06, iedep
  integer :: npos, nsta, k, i, j, kk, iz, ilat, ilon
  integer :: iedt, limit, last
  real :: yp, xp, xpos1, ypos1, avlat
  real :: dist1, dist2, dist3, dist4
  real :: d1, d2, d3, d4, xnorm, x1, x2, x3, x4
  real :: temp, bathsave

  integer :: iostat

  ! Initialize file defaults (filenames only, no paths)
  cruise     = 'p340811.dat'
  edepfile   = 'edeps-old'
  edepfilenew= 'p210704a-edep'
  bathfile   = 'bath1.dat'
  bathfilenew= 'p210704a-bath'
  ofil       = 'p060907c.10'
  bathname   = 'px05-sns-bath.cgi'
!               1234567890
  bathname2  = 'px06-sns-bath.cgi'

  ! Get cruise name from user
  write(*,*) 'enter cruise name: (p340811a)'
  read(*,'(a8)') cr

  ofil(1:8)    = cr(1:8)
  cruise(1:7)  = cr(1:7)
! Set bathname based on cruise assuming for now pxNN
  bathname(3:4) = cruise(2:3)

! This one is 'ps'
  if(cruise(1:3).eq.'s37') then
      bathname = 'ps37-sns-bath.cgi'
  endif

  if(cruise(1:3)== 'p40' .or. cruise(1:3) == 'p44') then
      bathname = 'px37-sns-bath.cgi'
  endif

  if(cruise(1:3).eq.'p13') then
      bathname = 'p09-sns-bath.cgi'
  endif

  ! Modify filenames based on cruise
  if (cr(1:3) == 'p06' .or. cr(1:3) == 'p09' .or. cr(1:3) == 'p13') then
    edepfile(5:5) = cr(8:8)
    bathfile(5:5) = cr(8:8)
    write(*,*) 'opening edepfile=', trim(edepfile)
    open(25, file=trim(edepfile), status='old', form='formatted', iostat=iostat)
    if (iostat /= 0) goto 23
    write(*,*) 'opening bathfile=', trim(bathfile)
    open(30, file=trim(bathfile), status='unknown', form='formatted')

  else if (cr(2:3) == '15' .or. cr(2:3) == '21') then
    bathfile(5:5)     = cr(8:8)
    edepfilenew(1:8)  = cr(1:8)
    bathfilenew(1:8)  = cr(1:8)
    open(25, file=trim(edepfilenew), status='old', form='formatted', iostat=iostat)
    if (iostat /= 0) goto 23
    open(30, file=trim(bathfile), status='unknown', form='formatted')

  else
    open(25, file=trim(edepfile), status='old', form='formatted', iostat=iostat)
    if (iostat /= 0) goto 23
    open(30, file=trim(bathfile), status='unknown', form='formatted')
  end if

  ! Set Atlantic cruise naming rules
  if (cruise(1:3) == 'a07' .or. cruise(1:3) == 'a08' .or. &
      cruise(1:3) == 'a10' .or. cruise(1:3) == 'a18' .or. &
      cruise(1:3) == 'a97') then
    bathname = 'a08-sns-bath.cgi'
  end if

  ! Default
  iaddp06 = 0

  ! Dimensions based on cruise type
  select case (cruise(1:3))
    case ('p34')
      nblat = 704;  nblon = 1507
    case ('s37')
      nblat = 848;  nblon = 2401
    case ('p05')
      nblat = 3912; nblon = 904
    case ('p50')
      nblat = 3471; nblon = 6947
    case ('p06')
      nblat = 1384; nblon = 2935
    case ('p31')
      nblat = 637;  nblon = 1524
    case ('p37','p40','p44')
      nblat = 1629; nblon = 7310
    case ('p38')
      nblat = 3450; nblon = 1423
    case ('a07','a08','a10','a18','a97')
      nblat = 5655; nblon = 5950
    case ('p09','p13')
      nblat = 4403; nblon = 3841
      iaddp06 = 1
      write(*,*) 'opening bathname2: ', trim(bathname2)
      open(12, file=trim(bathname2), status='old', form='formatted')
      nblat2 = 1384; nblon2 = 2935
      do i = 1, nblat2
        do j = 1, nblon2
          read(12, *, end=777, iostat=iz) snslon2(j), snslat2(i), snsbath2(j,i)
          if (iz /= 0) goto 777
        end do
      end do
      close(12)
    case default
      if (cruise(2:3) == '15' .or. cruise(2:3) == '21') then
        nblat = 2718; nblon = 7195
        bathname = 'ix15-sns-bath.cgi'
      else
        stop 'need SnS file for this cruise'
      end if
  end select

  goto 999

23 continue
  stop 'Error opening required files'

777 continue
  write(*,*) 'Finished reading secondary bath file.'

999 continue
  write(*,*) 'Setup complete.'

!   ! Initialize data
!   cruise = 'p340811.dat'
!   edepfile = 'edeps-old'
!   edepfilenew = 'p210704a-edep'
!   bathfile = 'bath1.dat'
!   bathfilenew = 'p210704a-bath'
!   ofil = 'p060907c.10'
!   bathname = '/data/xbt/p05/px05-sns-bath.cgi'
! !             1234567890123456789012345678901
!   bathname2 = '/data/xbt/p06/px06-sns-bath.cgi'
  
!   ! Get cruise name from user
!   write(*,*) 'enter cruise name: (p340811a)'
!   read(5,'(a8)') cr
!   ofil(1:8) = cr(1:8)
!   cruise(1:7) = cr(1:7)
  
!   ! Set bathname based on cruise
!   bathname(11:13) = cruise(1:3)
!   bathname(17:18) = cruise(2:3)
  
!   if (cruise(1:3) == 's37') then
!     bathname(16:16) = cruise(1:1)
!   end if
  
!   if (cruise(1:3) == 'p40') then
!     bathname(11:13) = 'p37'
!     bathname(17:18) = '37'
!   end if
  
!   if (cruise(1:3) == 'p44') then
!     bathname(11:13) = 'p37'
!     bathname(17:18) = '37'
!   end if
  
!   if (cruise(1:3) == 'p13') then
!     bathname(11:13) = 'p09'
!     bathname(17:18) = '09'
!   end if
  
!   ! Open files based on cruise type
!   if (cr(1:3) == 'p06' .or. cr(1:3) == 'p09' .or. cr(1:3) == 'p13') then
!     edepfile(5:5) = cr(8:8)
!     bathfile(5:5) = cr(8:8)
!     write(*,*) 'opening edepfile=', edepfile
!     open(25, file=edepfile, status='old', form='formatted', iostat=i)
!     if (i /= 0) goto 2
!     write(*,*) 'opening bathfile=', bathfile
!     open(30, file=bathfile, status='unknown', form='formatted')
!   else if (cr(2:3) == '15' .or. cr(2:3) == '21') then
!     bathfile(5:5) = cr(8:8)
!     edepfilenew(1:8) = cr(1:8)
!     bathfilenew(1:8) = cr(1:8)
!     open(25, file=edepfilenew, status='old', form='formatted', iostat=i)
!     if (i /= 0) goto 2
!     open(30, file=bathfile, status='unknown', form='formatted')
!   else
!     open(25, file=edepfile, status='old', form='formatted', iostat=i)
!     if (i /= 0) goto 2
!     open(30, file=bathfile, status='unknown', form='formatted')
!   end if
  
!   ! Set bathname for Atlantic cruises
!   if (cruise(1:3) == 'a07' .or. cruise(1:3) == 'a08' .or. &
!       cruise(1:3) == 'a10' .or. cruise(1:3) == 'a18' .or. &
!       cruise(1:3) == 'a97') then
!     bathname(15:15) = 'a'
!     bathname(11:13) = 'a08'
!     bathname(17:18) = '08'
!   end if
  
!   ! Set dimensions based on cruise
!   iaddp06 = 0
  
!   select case (cruise(1:3))
!     case ('p34')
!       nblat = 704
!       nblon = 1507
!     case ('s37')
!       nblat = 848
!       nblon = 2401
!     case ('p05')
!       nblat = 3912
!       nblon = 904
!     case ('p50')
!       nblat = 3471
!       nblon = 6947
!     case ('p06')
!       nblat = 1384
!       nblon = 2935
!     case ('p31')
!       nblat = 637
!       nblon = 1524
!     case ('p37', 'p40', 'p44')
!       nblat = 1629
!       nblon = 7310
!     case ('p38')
!       nblat = 3450
!       nblon = 1423
!     case ('a07', 'a08', 'a10', 'a18', 'a97')
!       nblat = 5655
!       nblon = 5950
!     case ('p09', 'p13')
!       nblat = 4403
!       nblon = 3841
!       iaddp06 = 1
!       write(*,*) 'opening bathname2: ', bathname2
!       open(12, file=bathname2, status='old', form='formatted')
!       nblat2 = 1384
!       nblon2 = 2935
!       do i = 1, nblat2
!         do j = 1, nblon2
!           read(12, 500, end=777, iostat=iz) snslon2(j), snslat2(i), snsbath2(j,i)
!           if (iz /= 0) goto 777
!         end do
!       end do
!       close(12)
!     case default
!       if (cruise(2:3) == '15' .or. cruise(2:3) == '21') then
!         nblat = 2718
!         nblon = 7195
!         bathname(12:13) = '15'
!         bathname(15:18) = 'ix15'
!       else
!         stop 'need SnS file for this cruise'
!       end if
!   end select
  
  if (nblat > nblatmax) stop 'redimension nblatmax'
  if (nblon > nblonmax) stop 'redimension nblonmax'
  
  ! Handle track assignment for p31
  atrack = 'A'
  if (cr(1:3) == 'p31') then
    open(15, file='/data/xbt/xbtinfo.p31', status='old', form='formatted')
    read(15,*)  ! skip 3 header lines
    read(15,*)
    read(15,*)
    do iz = 1, 100
      read(15,'(a4,25x,i1)', end=22) c, i
      if (c(1:4) == cruise(4:7)) then
        select case (i)
          case (1); atrack = 'A'
          case (2); atrack = 'B'
          case (3); atrack = 'C'
          case (4); atrack = 'D'
          case (5); atrack = 'E'
        end select
        exit
      end if
    end do
22  close(15)
  else if (cr(1:3) == 'p06' .or. cr(1:3) == 'p09' .or. cr(1:3) == 'p13') then
    write(*,*) 'opening ofil =', ofil
    open(47, file=ofil, status='old', form='formatted')
    read(47,'(i4)') nsta
    write(*,*) 'nsta in ', ofil, ' =', nsta
    do i = 1, nsta
      read(47,'(37x,i3)') idn(i)
      do j = 1, 8
        read(47,*)  ! skip 8 lines of data
      end do
    end do
    close(47)
  end if
  
  ! Open main data files
  write(*,*) 'opening ', bathname
  open(10, file=bathname, status='old', form='formatted', iostat=i)
  if (i /= 0) goto 778
  
  write(*,*) 'opening ', cruise
  open(20, file=cruise, status='old', form='formatted', iostat=i)
  if (i /= 0) goto 779
  
  open(33, file='errorSnS', status='unknown', form='formatted')
  open(35, file='../e-sns.txt', status='unknown', access='append', form='formatted')
  
  ! Set iedep flag
  iedep = 1
  goto 3
2 iedep = 0
3 continue
  
  ! Read SnS data
  do i = 1, nblat
    do j = 1, nblon
      read(10, 500, end=770, iostat=iz) snslon(j), snslat(i), snsbath(j,i)
500   format(2f9.4, f10.2)
      if (iz /= 0) goto 770
    end do
  end do
  close(10)
  write(*,*) 'finish reading file ', bathname
  
  ! Initialize output
  npos = 0
  write(30, 510)
510 format(' long    lat      final     SnS       E   code')
  
  ! Main processing loop
  do k = 1, 1000
7   read(20, 520, end=12, iostat=i) dropno, yp, xp, iedt
520 format(1x, a3, 32x, f8.3, 1x, f8.3, 7x, i2)
    if (i /= 0 .or. dropno(1:3) == 'NDD') goto 12
    
    read(dropno,'(i3)') j
    write(*,*) 'cruise=', cruise, 'dropno=', dropno
    
    ! Check if drop number is in our list for p06/p09/p13
    if (cr(1:3) == 'p06' .or. cr(1:3) == 'p09' .or. cr(1:3) == 'p13') then
      do kk = 1, nsta
        if (j == idn(kk)) goto 43  ! use it
      end do
      goto 7  ! skip it
    end if
43  continue
    
    ! Skip bad data
    if (iedt == -1 .or. iedt == -4 .or. iedt == -2 .or. iedt == -6) goto 7
    write(*,*) 'iedt=', iedt
    
    if ((cr(1:3) /= 'p31' .and. cr(1:3) /= 'p34' .and. cr(1:1) /= 'a') .and. iedt == 2) goto 7
    
    ypos(k) = yp
    xpos(k) = xp
    write(*,*) 'iedep=', iedep
    
    ! Read edeps file if available
    if (iedep == 1) then
88    read(25, 521, end=12, iostat=i) xpos1, ypos1, edep(k), lcode
      if (i /= 0) then
        write(*,*) 'edep:', xpos1, ypos1, edep(k), lcode
      end if
      if (lcode(1:3) == 'ADD') then
        write(30, 504) xpos1, ypos1, edep(k), edep(k), edep(k), lcode, edep(k)
        goto 88
      end if
      if (ypos(k) /= ypos1) then
        write(*,*) ypos(k), ypos1, iedt, dropno, yp, xp
        stop 'check positions between p*.dat and deps'
      end if
    else
      edep(k) = 999.0
      lcode(1:2) = 'no'
    end if
    
    npos = npos + 1
521 format(2f8.3, f8.0, 1x, a5)
    
    ! Process bathymetry data
    if (iaddp06 == 0 .or. (iaddp06 == 1 .and. ypos(k) >= -17.8934)) then
      ! Regular processing - find surrounding latitude
      ilat = 0
      ilon = 0
      do i = 1, nblat-1
        if (ypos(k) <= snslat(i) .and. ypos(k) >= snslat(i+1)) then
          ilat = i
          exit
        end if
      end do
      
      ! Find surrounding longitude
      do j = 1, nblon-1
        if (xpos(k) >= snslon(j) .and. xpos(k) <= snslon(j+1)) then
          ilon = j
          exit
        end if
      end do
      
      write(33,*) 'after 46: '
      write(33,*) 'xbt lat,lon=', ypos(k), xpos(k)
      write(33,*) 'ilat,ilon ', ilat, ilon
      
      if (ilat == 0 .or. ilon == 0) then
        bath(k) = 999.0
        sns(1) = 999.0
        sns(2) = 999.0
        sns(3) = 999.0
        sns(4) = 999.0
        goto 121
      end if
      
      if (ilon+1 > nblon) stop 'AA need more longs in SnS'
      if (ilat+1 > nblat) stop 'AA need more lats in SnS'
      
      ! Calculate distances to four corners
      avlat = (snslat(ilat) + ypos(k)) / 2.0
      dist1 = sqrt((snslat(ilat) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon(ilon) - xpos(k)))**2)
      
      avlat = (snslat(ilat) + ypos(k)) / 2.0
      dist2 = sqrt((snslat(ilat) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon(ilon+1) - xpos(k)))**2)
      
      avlat = (snslat(ilat+1) + ypos(k)) / 2.0
      dist3 = sqrt((snslat(ilat+1) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon(ilon+1) - xpos(k)))**2)
      
      avlat = (snslat(ilat+1) + ypos(k)) / 2.0
      dist4 = sqrt((snslat(ilat+1) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon(ilon) - xpos(k)))**2)
      
      write(33,*) snslat(ilat), snslon(ilon), snsbath(ilon,ilat)
      write(33,*) 'dist1: ', dist1
      write(33,*) snslat(ilat), snslon(ilon+1), snsbath(ilon+1,ilat)
      write(33,*) 'dist2: ', dist2
      write(33,*) snslat(ilat+1), snslon(ilon+1), snsbath(ilon+1,ilat+1)
      write(33,*) 'dist3: ', dist3
      write(33,*) snslat(ilat+1), snslon(ilon), snsbath(ilon,ilat+1)
      write(33,*) 'dist4: ', dist4
      
      ! Check for exact matches
      if (dist1 == 0.0) then
        bath(k) = snsbath(ilon, ilat)
      else if (dist2 == 0.0) then
        bath(k) = snsbath(ilon+1, ilat)
      else if (dist3 == 0.0) then
        bath(k) = snsbath(ilon+1, ilat+1)
      else if (dist4 == 0.0) then
        bath(k) = snsbath(ilon, ilat+1)
      else
        ! Weighted average interpolation
        d1 = 1.0 / dist1**2
        d2 = 1.0 / dist2**2
        d3 = 1.0 / dist3**2
        d4 = 1.0 / dist4**2
        xnorm = d1 + d2 + d3 + d4
        
        x1 = d1 / xnorm
        x2 = d2 / xnorm
        x3 = d3 / xnorm
        x4 = d4 / xnorm
        write(33,*) 'mults:', x1, x2, x3, x4
        
        bath(k) = snsbath(ilon,ilat) * x1 + snsbath(ilon+1,ilat) * x2 + &
                  snsbath(ilon+1,ilat+1) * x3 + snsbath(ilon,ilat+1) * x4
      end if
      
      bathave(k) = bath(k)
      sns(1) = snsbath(ilon, ilat)
      sns(2) = snsbath(ilon+1, ilat)
      sns(3) = snsbath(ilon+1, ilat+1)
      sns(4) = snsbath(ilon, ilat+1)
      
    else
      ! Process p09 cruises in p06 area
      do i = 1, nblat2-1
        if (ypos(k) <= snslat2(i) .and. ypos(k) >= snslat2(i+1)) then
          ilat = i
          exit
        end if
      end do
      
      do j = 1, nblon2-1
        if (xpos(k) >= snslon2(j) .and. xpos(k) <= snslon2(j+1)) then
          ilon = j
          exit
        end if
      end do
      
      write(*,*) 'after 446, ', ypos(k), xpos(k)
      write(*,*) 'ilon=', ilon
      write(*,*) 'nblon2=', nblon2
      
      if (ilon+1 > nblon2) stop 'BB need more longs in SnS'
      if (ilat+1 > nblat2) stop 'BB need more lats in SnS'
      
      ! Calculate distances for p06 area
      avlat = (snslat2(ilat) + ypos(k)) / 2.0
      dist1 = sqrt((snslat2(ilat) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon2(ilon) - xpos(k)))**2)
      
      avlat = (snslat2(ilat) + ypos(k)) / 2.0
      dist2 = sqrt((snslat2(ilat) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon2(ilon+1) - xpos(k)))**2)
      
      avlat = (snslat2(ilat+1) + ypos(k)) / 2.0
      dist3 = sqrt((snslat2(ilat+1) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon2(ilon+1) - xpos(k)))**2)
      
      avlat = (snslat2(ilat+1) + ypos(k)) / 2.0
      dist4 = sqrt((snslat2(ilat+1) - ypos(k))**2 + &
                   (cos(avlat*deg2rad) * (snslon2(ilon) - xpos(k)))**2)
      
      write(33,*) 'ilat,ilon ', ilat, ilon
      write(33,*) snslat2(ilat), snslon2(ilon), snsbath2(ilon,ilat)
      write(33,*) 'dist1: ', dist1
      write(33,*) snslat2(ilat), snslon2(ilon+1), snsbath2(ilon+1,ilat)
      write(33,*) 'dist2: ', dist2
      write(33,*) snslat2(ilat+1), snslon2(ilon+1), snsbath2(ilon+1,ilat+1)
      write(33,*) 'dist3: ', dist3
      write(33,*) snslat2(ilat+1), snslon2(ilon), snsbath2(ilon,ilat+1)
      write(33,*) 'dist4: ', dist4
      
      if (dist1 == 0.0) then
        bath(k) = snsbath2(ilon, ilat)
      else if (dist2 == 0.0) then
        bath(k) = snsbath2(ilon+1, ilat)
      else if (dist3 == 0.0) then
        bath(k) = snsbath2(ilon+1, ilat+1)
      else if (dist4 == 0.0) then
        bath(k) = snsbath2(ilon, ilat+1)
      else
        ! Weighted average
        d1 = 1.0 / dist1**2
        d2 = 1.0 / dist2**2
        d3 = 1.0 / dist3**2
        d4 = 1.0 / dist4**2
        xnorm = d1 + d2 + d3 + d4
        
        x1 = d1 / xnorm
        x2 = d2 / xnorm
        x3 = d3 / xnorm
        x4 = d4 / xnorm
        write(33,*) 'mults:', x1, x2, x3, x4
        
        bath(k) = snsbath2(ilon,ilat) * x1 + snsbath2(ilon+1,ilat) * x2 + &
                  snsbath2(ilon+1,ilat+1) * x3 + snsbath2(ilon,ilat+1) * x4
      end if
      
      bathave(k) = bath(k)
      sns(1) = snsbath2(ilon, ilat)
      sns(2) = snsbath2(ilon+1, ilat)
      sns(3) = snsbath2(ilon+1, ilat+1)
      sns(4) = snsbath2(ilon, ilat+1)
    end if
    
    ! Sort sns array (bubble sort)
    limit = 4
111 if (limit <= 1) goto 121
    last = 0
    do i = 1, limit-1
      if (sns(i) <= sns(i+1)) goto 20
      temp = sns(i)
      sns(i) = sns(i+1)
      sns(i+1) = temp
      last = i
20    continue
    end do
    limit = last
    goto 111

121 continue
    write(33,*) 'sns= ', bath(k), '  edep= ', edep(k)
    write(33,*) sns(1), sns(2), sns(3), sns(4)
    
    bathsave = bath(k)
    
    ! Check if edep is in SnS range
    arange = 'N'
    if (edep(k) /= 999.0) then
      if (edep(k) >= sns(1) .and. edep(k) <= sns(4)) arange = 'Y'
    end if
    
    ! Process depth comparisons
    if (edep(k) == 999.0) then
      write(33,*) 'no edep'
      goto 49
    else if (lcode(1:2) == 'HB') then
      bath(k) = edep(k)
      bathave(k) = edep(k)
      write(35,524) cruise(4:7), xpos(k), ypos(k), bathsave, &
                    edep(k), lcode, sns(1), sns(2), sns(3), sns(4), &
                    bathsave-edep(k), arange, atrack
    else if (lcode(1:3) == 'C34' .or. lcode(1:3) == 'LST' .or. lcode(1:3) == 'C12') then
      if (edep(k) > -800.0) then
        if (bath(k) > -800.0) then
          if (edep(k) < bath(k)) then
            bath(k) = edep(k)
            bathave(k) = edep(k)
          end if
          if (edep(k) > bath(k)) then
            if (lcode(1:3) == 'LST') then
              bath(k) = edep(k)
              bathave(k) = edep(k)
            end if
          end if
        else if (bath(k) <= -800.0) then
          bath(k) = -800.0
          bathave(k) = bathsave
        end if
      else if (edep(k) <= -800.0) then
        bath(k) = -800.0
        if (edep(k) < bathsave) then
          bathave(k) = edep(k)
        else
          bathave(k) = bathsave
        end if
      end if
    else if (edep(k) < bath(k)) then
      write(33,*) 'change bath(k) to ', edep(k)
      bath(k) = edep(k)
      bathave(k) = edep(k)
      write(35,524) cruise(4:7), xpos(k), ypos(k), bathsave, &
                    edep(k), lcode, sns(1), sns(2), sns(3), sns(4), &
                    bathsave-edep(k), arange, atrack
      write(33,*) 'finish writing 35'
    else if (edep(k) > bath(k)) then
      if (lcode(1:2) == 'HB') then
        write(33,*) k, ' HB: change bath(k) to ', edep(k), ' from ', bath(k)
        bath(k) = edep(k)
        bathave(k) = edep(k)
        if (edep(k) > -800.0) then
          write(35,524) cruise(4:7), xpos(k), ypos(k), bathsave, &
                        edep(k), lcode, sns(1), sns(2), sns(3), sns(4), &
                        bathsave-edep(k), arange, atrack
        end if
      else if (lcode(4:5) == '-R') then
        write(33,*) k, ' -R: change bath(k) to '
        bath(k) = -800.0
        bathave(k) = bathsave
      else if (lcode(4:5) == '  ') then
        write(33,*) k, ' NO -R: change bath(k) to ', edep(k)
        bath(k) = edep(k)
        bathave(k) = edep(k)
        if (bath(k) < -800.0) then
          bath(k) = -800.0
          bathave(k) = bathsave
        end if
      else
        if (edep(k) > -800.0) then
          write(35,524) cruise(4:7), xpos(k), ypos(k), bathsave, &
                        edep(k), lcode, sns(1), sns(2), sns(3), sns(4), &
                        bathsave-edep(k), arange, atrack
        end if
      end if
    end if

49  continue
    write(33,*) ' ', bath(k)
    write(30,504) xpos(k), ypos(k), bath(k), bathsave, edep(k), lcode, bathave(k)
524 format(a4, 2f8.3, 1x, f6.0, 1x, f6.0, 1x, a3, 1x, 5(f6.0), 1x, a1, 1x, a1)
enddo
50 continue
12 continue
   
   goto 800

770 stop ' end cgi file'
778 stop ' error opening bathname'  
779 stop ' error opening cruise'

800 continue
504 format(2f8.3, f8.0, 1x, f8.0, 1x, f8.0, 1x, a5, 1x, f8.0)

end program mkcruisebath
