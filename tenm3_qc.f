! tenm3.f
! 02jan2019 LL - make sure nbin>0 before divide
! 13dec2017 LL add deal with qc codes since using meds-ascii files.
!
! 15jan2013 LL simplify input args so can run in batch without
!   having to type in first and last e file number, or use t-5?
!   and just 7 char input name (so can list p??????.dat as input)
!
! 22may01 LL - for p22 only - the missing data value is -9999
! 24jun99 LL : the .10 bug!  Change so last 10 m of e file get averaged
!        and added to the .10 file.  Has always skipped this before.
! 10-27-97 t5s: Only processing e files listed with a 1 in the
! edit column.  Prompt operator to include t5s.  If so, use
! e files marked with a 2 in edit col. LL
! Revised 8-4-94 to write date and time to .10 file - LL
! create 10 meter block averaged data and store in an array

       character efile*12, cr*8, cr1*1,ofil*11, sfile*11
       character*17 d, date(550), log*9
       character*3 dropno, dn(550), t5e*15, ans*1
       character*15 char15
       dimension iavt(90,550),xlat(550),xlon(550)
       data t5e/'t5/p099709e.001'/, log/'tenm3.log'/
       data efile/'p099105e.001'/,ofil/'p099105a.10'/,
     $       iavt/49500*0/, sfile/'p099105.dat'/,cr1/'a'/
!
       open(33,file=log,form='formatted',status='unknown')
       write(*,*)'Note! This does NOT change old coeffs to new coeffs.'
       write(*,*)'Use tenm3_chgcoef.x to change old coeffs to new!'
       write(*,*)
! prompt op for input
       write(*,*)' Enter cruise name:  (ie. p099105a) '
       read(5,'(a8)') cr(1:8)
! why did you do this?       cr(8:8) = 'a'
!       write(*,*)' Enter min and max "e" file numbers : (ie. 1 210) '
!       read(*,*)min,max
!       write(*,*)cr,min,max
       write(33,*)cr
!       write(*,*)' Include t5s in processing?  (y or n)'
!       read(5,'(a1)') ans
       ans = 'y'
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
          if(dropno(1:3).eq.'NDD') go to 100
          read(dropno,'(i3)') j
!          if(j.lt.min.or.j.gt.max) go to 20
! skip if iedt=-1 or -2:
!  or just plain old lt 0 :)
!          if(iedt.eq.-1.or.iedt.eq.-2) then
          if(iedt.lt.0) then
             write(*,*)'iedt = ',iedt, ' skipping ', dropno
             write(33,*)'iedt = ',iedt, ' skipping ', dropno
             go to 20
          endif
! skip if op says not to include t5's in processing:
! 02sep2008LL iedt=2 now meas deep blue new coef:
!          if(iedt.eq.2.and.ans(1:1).eq.'n') then
!             write(*,*)'iedt=2 (t5) you do not want t5s, skipping', dropno
!             write(33,*)'iedt=2 (t5) you do not want t5s, skipping',dropno
!             go to 20
!          endif
          nbin=0
          ibins=0
          write(efile(10:12),'(a3)') dropno
          write(*,*)'opening ', efile
          write(33,*)'opening ', efile
          open(8,file=efile,status='old',err=15,form='formatted')
          go to 16
! if error opening e file check if it's a t5.  If so, try opening
! t5/efile:
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
! skip 1st 2 lines of e file
          read(8,*)
          read(8,*)

! missing value = -9999 for p22 (a22)
! missing value = -999  for the rest
           if(cr(2:3).eq.'22') then
              do 50 k=1,90
50            iavt(k,nsta)=-9999
           else
              do 150 k=1,90
150           iavt(k,nsta)=-999
           endif

          do 30 k=1,450
            char15='               '
            read(8,'(a15)',err=21,end=21) char15
!            write(35,*) 'char15=',char15
            read(char15(1:3),'(i3)',err=21,end=21) idep
            read(char15(5:9),'(i5)',err=21,end=21) item
            read(char15(11:11),'(i1)',end=21,err=21) iclass
! if iclass=3 - probably bad - do not use it.
! perhaps add an if later if Dean wants to look at these:
            if((iclass.eq.3).or.(iclass.eq.4)) go to 21
!13dec2017 is this still true:
check - skip first bad bin on p22 per Janet
                if(cr(2:3).eq.'22'.and.idep.lt.2.0)goto 30
             ibin=idep/10 +1
             if(ibin.eq.ibins)then
         nbin=nbin+1
         av=av+float(item)
             else if (ibin.ne.ibins.and.nbin.ne.0) then
         av=av/float(nbin)
         iavt(ibins,nsta)=ifix(av)
         nbin=1
         av=float(item)
             else
         nbin=1
         av=float(item)
             endif
             ibins=ibin
30          continue
21          close(8)
! 24jun99 need to calc iavt for last bin:
! 02jan2018 check if nbin= zero here:
           if(nbin.gt.0) then
            av=av/float(nbin)
            iavt(ibins,nsta)=ifix(av)
           else
            iavt(ibins,nsta)=-999
           endif
20       continue
100       write(*,*)' nsta = ',nsta
       write(33,*)' nsta = ',nsta
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
