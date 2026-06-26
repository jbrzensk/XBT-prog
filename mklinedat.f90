program mklinedat
  implicit none

  character(len=70) :: line
  character(len=3)  :: drpn
  character(len=7)  :: cruise
  integer :: i, idy, imo, ihr, imn, iedt, ios
  real    :: xlat, xlon

  open(unit=10, file='/data1/xbt-archive/line.dat', &
       status='unknown', form='formatted')
  open(unit=20, file='stations.dat', &
       status='unknown', form='formatted')

  write(*,*) 'Enter cruise name:'
  read(*,'(a7)') cruise

  do i = 1, 1000
    read(20, '(a70)', iostat=ios) line
    if (ios /= 0) exit
    if (line(1:4) == 'ENDD') exit

    read(line, '(1x,a3,14x,i2,1x,i2,4x,i2,1x,i2,3x,f9.3,f9.3,7x,i2)') &
         drpn, idy, imo, ihr, imn, xlat, xlon, iedt

    ! p28: wpsxbt cannot handle iedt=+/-2, demote to +/-1
    if (cruise(2:3) == '28') then
      if (iedt ==  2) iedt =  1
      if (iedt == -2) iedt = -1
    end if

    write(10, '(a7,1x,a3,1x,i2,1x,i2,1x,i2,1x,i2,1x,f8.3,f8.3,1x,i2)') &
         cruise, drpn, idy, imo, ihr, imn, xlat, xlon, iedt
  end do

  close(10)
  close(20)

end program mklinedat
