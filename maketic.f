       program maketic
! tic marks for xbt drop locations for ferret file
! 20mar2019 rm tabs and add p13
       character snam*11, tnam*12, typ*3, ans*1, a1*1
       data snam/'p289403.dat'/, tnam/'station.tics'/
       write(*,*)'enter cruise name: (7 chars) (ie: p402303)'
       read(5,'(a7)') snam(1:7)
       write(*,*)' Include t5s? (y or n)'
       read(5,'(a1)') ans
        if(snam(1:3).eq.'p06') then
           write(*,*) 'is this a, b, or c ?'
           read(5,'(a1)') a1
        endif
 
       if(snam(1:3).eq.'p09'.or.snam(1:3).eq.'p28'.or.
     $     snam(1:3).eq.'p38'.or.snam(1:3).eq.'p81'.or.
     $     snam(1:3).eq.'p22'.or.snam(1:3).eq.'p06'.or.
     $     snam(1:3).eq.'p05'.or.snam(1:3).eq.'p13') then
           if(snam(1:3).eq.'p06'.and.a1(1:1).eq.'b') then
              typ(1:3)='lon'
           else
             typ(1:3) = 'lat'
           endif
       elseif(snam(2:3).eq.'15'.or.snam(1:3).eq.'p31'.or.
     $         snam(1:3).eq.'p34'.or.snam(1:3).eq.'p35'.or.
     $         snam(1:3).eq.'p37'.or.snam(1:3).eq.'p50'.or.
     $         snam(1:3).eq.'p08'.or.snam(2:3).eq.'21'.or.
     $         snam(1:3).eq.'i15'.or.snam(1:3).eq.'s37'.or.
     $         snam(1:3).eq.'p40'.or.snam(1:3).eq.'p44') then
             typ(1:3) = 'lon'
       else
             stop 'New cruise line!  Fix program for type'
       endif
       open(10,file=snam,form='formatted',status='old')
       open(20,file=tnam,form='formatted',status='unknown')
       do 100 i = 1, 500
          read(10,500,end=101) xlat, xlon, iedt
500          format(37x,f7.3,2x,f7.3,7x,i2)
          if(iedt.eq.-1) go to 100
          if(iedt.eq.-2) go to 100
          if(iedt.eq.-4) go to 100
          if(iedt.eq.2.and.ans.eq.'n') go to 100
          if(typ(1:3).eq.'lat') then
             write(20,501) xlat, 0
             write(20,501) xlat, -15
             write(20,501) xlat, 0
          else
             write(20,501) xlon, 0
             write(20,501) xlon, -15
             write(20,501) xlon, 0
          endif
501          format(f7.3, 2x, i3)
100       continue
101       continue
       close(10)
       close(20)
       stop
       end
       
