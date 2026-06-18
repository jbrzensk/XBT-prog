! 18apr2018 LL for p28 (my use only, not ship use) I must not
!   write iedt=2 or -2 for wpsxbt, so add p28 line that changes
!   iedt=2 to iedt=1, and iedt=-2 to iedt=-1...
!
! create one large line.dat file with just the important info <p09>.dat
! from each cruise stations.dat
       program mklinedat
!
       character*70 line
       character*3 drpn
       character*7 cruise
!
       open(10,file='/data1/xbt-archive/line.dat',status='unknown',
     $       form='formatted')
       open(20,file='stations.dat',status='unknown',form='formatted')

       write(6,*)'Enter cruise name:'
       read(5,501) cruise
501    format(a7)
!
       do 10 i = 1, 1000
          read(20,500,end=11,err=11) line
          if(line(1:4).eq.'ENDD') goto 11
          read(line,505)drpn,idy,imo,ihr,imn,xlat,xlon,iedt
500       format(a70)
505       format(1x,a3,14x,i2,1x,i2,4x,i2,1x,i2,3x,f9.3,f9.3,7x,i2)
! p28 mod:
          if(cruise(2:3).eq.'28') then
             if(iedt.eq.2)  iedt=1
             if(iedt.eq.-2) iedt=-1
          endif
! end p28 mod
          write(10,506)cruise,drpn,idy,imo,ihr, imn, xlat, xlon, iedt
506       format(a7,1x,a3,1x,i2,1x,i2,1x,i2,1x,i2,1x,f8.3,f8.3,1x,i2)
10     continue
11     continue
       close(10)
       close(20)
       stop
       end

