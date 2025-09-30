c tenm3_chgcoef.f
! 02jan2019 - make sure nbin>0 before divide
c 22may01 LL - for p22 only - the missing data value is -9999
c 24jun99 LL : the .10 bug!  Change so last 10 m of e file get averaged
c       and added to the .10 file.  Has always skipped this before.
c 12apr99 - this version of tenm3 reads in cruises done using OLD
c drop rate coefficients (b=6.472, a=-2.16) multiplies depth by 1.0336,
c to change to NEW coefficients (b=6.691, a=-2.25) LL
c
c 10-27-97 t5s: Only processing e files listed with a 1 in the
c edit column.  Prompt operator to include t5s.  If so, use
c e files marked with a 2 in edit col. LL
c Revised 8-4-94 to write date and time to .10 file - LL
C create 10 meter block averaged data and store in an array

       character efile*12, cr*8, cr1*1,ofil*11, sfile*11
       character*17 d, date(400), log*9, char15*15
       character*3 dropno, dn(400), t5e*15, ans*1
       dimension iavt(90,400),xlat(400),xlon(400)
       data t5e/'t5/p099709e.001'/, log/'tenm3.log'/
       data efile/'p099105e.001'/,ofil/'p099105a.10'/,
     $       iavt/36000*0/, sfile/'p099105.dat'/,cr1/'a'/
c
! type of probe counters:
       itest = 0
       ibad = 0
       it5 = 0
       open(33,file=log,form='formatted',status='unknown')
       write(*,*)'Note!  This changes OLD coeffs to NEW coeffs!'
       write(*,*)
c prompt op for input
       write(*,*)' Enter cruise name:(8 chars)  (ie. p099105a) '
       read(5,'(a8)') cr
       write(*,*)' Enter min and max "e" file numbers : (ie. 1 210) '
       read(*,*)min,max
       write(*,*)cr,min,max
       write(33,*)cr,min,max
       write(*,*)' Include t5s in processing?  (y or n)'
       read(5,'(a1)') ans
       write(33,*) 'Include t5s in processing? ', ans

       ofil(1:8)=cr(1:8)
       open(14, file=ofil, status='unknown',form='formatted')
       efile(1:7)=cr(1:7)
       t5e(4:10) = cr(1:7)
       nsta=0
       sfile(1:7) = cr(1:7)
       open(7,file=sfile,status='old',form='formatted')
       do 20 ii=1,1000
          read(7,500,end=100)dropno,d(1:17),xlt,xln,iedt
500          format(1x,a3,14x,a17,2f9.3,7x,i2)
          read(dropno,'(i3)') j
          if(j.lt.min.or.j.gt.max) go to 20
c skip if iedt=-1 or -2:
! 5jul2010 skip if iedt=-4= TP Test Probe
          if(iedt.eq.-1.or.iedt.eq.-2.or.iedt.eq.-4) then
             write(*,*)'iedt = ',iedt, ' skipping ', dropno
             write(33,*)'iedt = ',iedt, ' skipping ', dropno
              if(iedt.eq.-1) then
                 ibad = ibad + 1
              elseif(iedt.eq.-2) then
                 it5 = it5 + 1
              elseif(iedt.eq.-4) then
                 itest = itest + 1
              endif
             go to 20
          endif
c skip if op says not to include t5's in processing:
          if(iedt.eq.2.and.ans(1:1).eq.'n') then
             write(*,*)'iedt=2 (t5) you do not want t5s, skipping',
     $                  dropno
             write(33,*)'iedt=2 (t5) you do not want t5s, skipping',
     $                 dropno
             go to 20
          endif
          nbin=0
          ibins=0
          write(efile(10:12),'(a3)') dropno
          write(*,*)'NEW opening ', efile
          write(33,*)'NEW2 opening ', efile
          open(8,file=efile,status='old',err=15,form='formatted')
          go to 16
c if error opening e file check if it's a t5.  If so, try opening
c t5/efile:
15          if(iedt.eq.2) then
             write(t5e(13:15),'(a3)') dropno
             write(*,*)'try opening ', t5e
             write(33,*)'try opening ', t5e
             open(8,file=t5e,status='old',err=25,form='formatted')
          endif
16          continue
          nsta=nsta+1
          xlat(nsta)=xlt
          xlon(nsta)=xln
          dn(nsta)(1:3) = dropno(1:3)
          date(nsta)(1:17) = d(1:17)
c skip 1st 2 lines of e file
          read(8,*)
          read(8,*)

c missing value = -9999 for p22 (a22)
c missing value = -999  for the rest
          if(cr(2:3).eq.'22') then 
             do 50 k=1,90
50             iavt(k,nsta)=-9999
          else
             do 150 k=1,90
150             iavt(k,nsta)=-999
          endif

          do 30 k=1,450
            char15='               '
            read(8,'(a15)',err=21,end=21) char15
!            write(35,*) 'char15=',char15
            read(char15(1:3),'(i3)',err=21,end=21) idep
            read(char15(5:9),'(i5)',err=21,end=21) item
            read(char15(11:11),'(i1)',end=21,err=21) iclass
!            write(33,*) 'dep, tem, iclass =',idep, item, iclass
!            read(char15(13:15),'(a3)',end=21,err=21) code
! if iclass=3 - probably bad - do not use it.
! perhaps add an if later if Dean wants to look at these:
            if((iclass.eq.3).or.(iclass.eq.4)) go to 21
!            write(35,*) 'dep, tem1=',d(iz), t(iz)

!old:             read(8,*,end=21,err=21)idep,item
!             write(33,*)'using:',idep,item
check - skip first bad bin on p22 per Janet
                if(cr(2:3).eq.'22'.and.idep.lt.2.0)goto 30
c OLD             ibin=idep/10 +1
c OLD -> NEW coef change:
             ibin = int( ( ( real(idep) * 1.0336 ) / 10.0 ) + 1.0 )
!             write(33,*)'ibin=',ibin,' nbin=',nbin,' av=',av,
!     $' ibins=', ibins
             if(ibin.eq.ibins)then
                nbin=nbin+1
                av=av+float(item)
             else if (ibin.ne.ibins.and.nbin.ne.0) then
                av=av/float(nbin)
                iavt(ibins,nsta)=ifix(av)
!       write(33,*) 'fin , iavt(ibins,nsta)=',iavt(ibins,nsta),
!     $' nsta=',nsta
                nbin=1
                av=float(item)
             else
                nbin=1
                av=float(item)
             endif
             ibins=ibin
30          continue
21          close(8)
c 24jun99 need to calc iavt for last bin:
           if(nbin.gt.0) then
           av=av/float(nbin)
           iavt(ibins,nsta)=ifix(av)
           else
          iavt(ibins,nsta)=-999
          if(cr(2:3).eq.'22') iavt(ibins,nsta)=-9999
           endif
20       continue
100       write(*,*)' nsta = ',nsta
       write(33,*)' nsta = ',nsta
          write(*,*)' Number of test drops = ',itest
          write(33,*)' Number of test drops = ',itest
          write(*,*)' Number of bad drops = ',ibad
          write(33,*)' Number of bad drops = ',ibad
          write(*,*)' Number of t5 drops = ',it5 
          write(33,*)' Number of t5 drops = ',it5 
       write(14,'(i4)')nsta
       do 60 i=1,nsta
          write(14,'(2f9.3,1x,a17,1x,a3)')xlat(i),xlon(i),date(i),dn(i)
          write(14,'(12i6)')(iavt(k,i),k=1,90)
60       continue
       write(*,*)
       write(*,*)' Output written to tenm3.log '
       stop
25       write(*,*)' You said to include t5 e files in processing, but'
       write(*,*)' I cannot find ', dropno ,' in either the main dir'
       write(*,*)' or the t5 dir'
       write(33,*)' You said to include t5 e files in processing, but'
       write(33,*)' I cannot find ', dropno ,' in either the main dir'
       write(33,*)' or the t5 dir'
       write(*,*)
       write(*,*)' Output written to tenm3.log '
       stop
      end
