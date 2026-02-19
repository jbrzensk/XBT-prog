! 5jan2011 LL mods to make universal.  Currently opens bath1.dat in
! cruise dir (created by find-e-dep.f,mkcruisebath.f(SnS))
!
! this is a sticky program.  Always check the output to be sure I
! got the right surface and bottom (especially at 800m)
! nx=tot lat or lonn div by .1 + 1
       parameter(nxmax=1300)
       parameter(nymax=86)
       parameter(nbath=600)
! ss parameter(nx=665,ny=86)
!       parameter(nx=1129,ny=86)
! bl    parameter(nx=244,ny=86)
! hv    parameter(nx=398,ny=86)
! ko taiwan-Hono-SF parameter(nx=1166,ny=86)
! sw    parameter(nx=219,ny=86)
! es    parameter(nx=196,ny=86)
! p15   parameter(nx=839,ny=86)
! p81hc parameter(nx=581,ny=86)
! p81hp parameter(nx=644,ny=86)
! p37 hk-sf parameter(nx=1216,ny=86)
! p50 ca parameter(nx=1065,ny=86)
! p50 vl parameter(nx=1151,ny=86)
! p31 b2 parameter(nx=253,ny=86)
! p31 b3 parameter(nx=243,ny=86)
! p31 b4 parameter(nx=254,ny=86)
! p31 b1 parameter(nx=242,ny=86)
! ix21/ix06 parameter(nx=638,ny=86)
! p08: a-p?  parameter(nx=1051,ny=86)
! p050908 (-27 to 35) parameter(nx=621,ny=86)
! s37 202.25 to 241.65:parameter(nx=395,ny=86)
!
        character*8 cruise
        character*3 latlon
        character*12 temfile
        character*9 bathin
        character*13 bathinnew
        character*9 bathout
        character*13 bathoutnew
        dimension glat(nxmax), gdep(nxmax), dep(nymax), igrid(nxmax)
        dimension xlon(nbath), xlat(nbath), xdep(nbath)
        dimension xlat2(nbath), xdep2(nbath)
        data temfile/'s371006a.tem'/
        data bathin/'bath1.dat'/
        data bathinnew/'p210704a-bath'/
        data bathout/'bath1.grd'/
        data bathoutnew/'p210704a-bgrd'/

!
       write(*,*)'enter cruise (a8)'
       read(5,'(a8)') cruise(1:8)
       if(cruise(2:3).eq.'15') then
          temfile(1:7) = cruise(1:7)
       else
          temfile(1:8) = cruise(1:8)
       endif
! This sets the bath file to batha.dat,
       if(cruise(2:3).eq.'06'.or.cruise(2:3).eq.'09'.or.
     $    cruise(2:3).eq.'15'.or.cruise(1:3).eq.'i21'.or.
     $    cruise(2:3).eq.'13') then
          bathin(5:5) = cruise(8:8)
          bathout(5:5) = cruise(8:8)
       endif
       write(*,*)'bathin=',bathin
! input:
       open(10,file=bathin,form='formatted',status='old')
! output:
       open(20,file=bathout,form='formatted',status='unknown')
       open(33,file='mkbotgrd.out',form='formatted',status='unknown')
!
! dimensions:
! ny is 86 depths:
       ny=86
! let's try to read .tem file to get xleft and xright 
       write(33,*)'opening tem file:', temfile
       open(30,file=temfile,status='old',form='formatted',err=77)
       go to 78
77     stop 'you need to run mapxbt3.x first to create the tem file'
78     continue
       read(30,511) nx,ny,xleft,xright,ybot,ytop
       write(33,*) 'from tem file:',nx,ny,xleft,xright,ybot,ytop
511    format(2i8,2f8.2,2f8.0)
       close(30)
! think about this, do I need to set up a left and right inside bath1.dat?
!       if(cruise(1:3).eq.'s37')then
! s37 202.25 to 241.65:parameter(nx=395,ny=86)
!          nx=395
!       elseif(cruise(1:3).eq.'p05')then
!          nx=621
!       else
!          stop 'add dimension of this line to mkbotgrd.f'
!       endif
!
       latlon = 'lat'
       if(cruise(1:3).eq.'s37'.or.cruise(1:3).eq.'p37'.or.
     $    cruise(1:3).eq.'p31'.or.cruise(1:3).eq.'p34'.or.
     $    cruise(1:3).eq.'i21'.or.cruise(1:3).eq.'i15'.or.
     $    cruise(2:3).eq.'15'.or.cruise(1:3).eq.'p50'.or.
     $    cruise(1:3).eq.'p08'.or.cruise(1:3).eq.'p40'.or.  
     $    cruise(1:3).eq.'a07'.or.cruise(1:3).eq.'a18'.or.
     $    cruise(1:3).eq.'a97'.or.cruise(1:3).eq.'p44') then
          latlon = 'lon'
       elseif(cruise(1:3).eq.'p06') then
          if(cruise(8:8).eq.'a') then
             latlon = 'lat'
             close(10)
             open(10,file='batha.dat',form='formatted',status='old')
             close(20)
             open(20,file='batha.grd',form='formatted',status='unknown')
          elseif(cruise(8:8).eq.'b') then
             latlon = 'lon'
             close(10)
             open(10,file='bathb.dat',form='formatted',status='old')
             close(20)
             open(20,file='bathb.grd',form='formatted',status='unknown')
          elseif(cruise(8:8).eq.'c') then
             latlon = 'lat'
             close(10)
             open(10,file='bathc.dat',form='formatted',status='old')
             close(20)
             open(20,file='bathc.grd',form='formatted',status='unknown')
          endif
       endif
       write(33,*)'latlon=',latlon
! skip first line of bath1.dat (header)
       read(10,*) 
       do 10 i = 1, nbath
           read(10,500,end=11,err=11) xlon(i),xlat(i), xdep(i)
           write(33,*) i, xlat(i), xdep(i)
! longitude:
           if(latlon.eq.'lon') then
              write(33,*)'set xlat(i) to lon:',xlat(i) 
              xlat(i) = xlon(i)
              write(33,*) 'now set at:',xlat(i) 
           endif
10     continue
       stop 'redimension nbath'
11     continue
       n = i-1
500    format(2f8.3,f8.0)   ! bath1.dat format 5jan2011
! ss 500       format(f6.2,f6.0)
!    500       format(f7.2,f6.0)
!    500       format(f8.3,f8.0)

! bozo workaround for that rounding bug...
        write(33,*) 'test ',xlat(1), xlat(n) , n
! find lowest lat/lon and work up, might need to swap arrays around
        if(xlat(1).gt.xlat(n)) then
           write(33,*) 'test again',xlat(1), xlat(n) , n
!           glat(1) = xlat(n)*1000.
           nn = n
           do 62 is = 1, n
              xlat2(is) = xlat(nn)
              xdep2(is) = xdep(nn)
              nn = nn-1
62         continue
           do 23 is = 1, n
              xlat(is) = xlat2(is)
              xdep(is) = xdep2(is)
              write(33,*)'new ', is, xlat(is), xdep(is)
23         continue
        else
!           glat(1) = xlat(1)*1000.
        endif
! set glat(1) from .tem file:
        glat(1) = xleft*1000.0

        write(33,*) 'glat(1)=',glat(1)
        xc = 0.1 * 1000.0
        do 20 i = 2, nx 
           glat(i) = glat(i-1) + xc
20      continue
        do 19 i = 1, nx 
           glat(i) = glat(i)/1000.0
           write(33,*)i, glat(i)
19      continue

        dep(1) = 1000.0
        do 21 i = 2, ny
           dep(i) = dep(i-1) - 10.0
21      continue
        do 22 i = 1, ny
           dep(i) = dep(i) - 1000.0
22      continue

! why was this nx-1?        do 30 i = 1, nx-1
! try nx:
        do 30 i = 1, nx
           do 25 j = 1, n
              if(glat(i).eq.xlat(j)) then
                 gdep(i) = xdep(j)
                write(33,*)'glat ',glat(i),'=',xlat(i), gdep(i)
                 go to 30
              endif
              if(glat(i).lt.xlat(j)) then
                write(33,*)glat(i), '<',xlat(j)
                 x1 = (xlat(j-1) - glat(i))/(xlat(j-1) - xlat(j))
                 x2 = (glat(i) - xlat(j))/(xlat(j-1) - xlat(j))
                 gdep(i) = x1*xdep(j) + x2*xdep(j-1)
                write(33,*) '< ',glat(i), gdep(i)
                 go to 30
! added 24nov2010:
              elseif(glat(i).gt.xlat(n)) then
                 gdep(i) = xdep(n)
                 go to 30
              endif
25         continue 
30      continue
!
! this was set here because of nx-1 above, comment out and test:        gdep(nx) = xdep(n)
!output to bath.grd:
        write(20,*) nx,ny, glat(1), glat(nx), 850.0, 0.0
        do 50 j = 1, ny
        do 40 i = 1, nx
           igrid(i) = 0
           if(j.eq.1.and.dep(j).le.gdep(i)) then
              if(j.eq.81) write(33,*) j, dep(j),'<',i, gdep(i)
              igrid(i) = 9
           endif
! adding 0.001 for those pesky bottom blips
           if(j.ne.1.and.dep(j)+0.001.lt.gdep(i)) then
              if(j.eq.81)write(33,*)glat(i),j,dep(j),'<',i,gdep(i)
              igrid(i) = 9
           else
              if(j.eq.81)write(33,*)glat(i),j,dep(j),'>=',i,gdep(i)
           endif

40      continue
        write(20,501)(igrid(k),k=1,nx)
501     format(40i2)
50      continue
        stop
        end
