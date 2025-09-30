! 14mar2019 LL - Look for "ENDD" in stations.dat to exit gracefully
! 20jun2012 LL - need cruise names for output files in p15 since
!    multiple cruises
! 22may2012 LL - mods for p06 a b c - try using a.10, b.10, c.10 to 
!  create edeps-a, -b -c ?
!18nov2010 LL ignore iedt=-4=TP's, and why is depth +2m ? add drop number to edeps-old too
!26oct2010 LL drat, need to recreate edeps of REAL edeps (not the range I did below).

! 14oct2010 PX31 mods!   not quite started.   add reading xbtinfo to
! get track, then have a range of xbt or 800 for each range...
! for tracks that visit Noumea, add one extra 166.75 0 depth

! Use -800m for lev0.   May want to change someday...
        parameter (xlev0=-800.0)
!
        character efile*12, cr*8, cr1*1,ofil*11, sfile*11
	character*17 d, date(600), log*9, chr14*14, chr14a*14
	character*3 dropno, dn(600), t5e*15, ans*1
        character*4 c, atrack*1
        character*9 edepfile
        character*13 edepfilenew
        dimension iavt(90,600),xlat(600),xlon(600)
        dimension idn(600)
	data t5e/'t5/p099709e.001'/, log/'tenm3.log'/
	data efile/'p099105e.001'/,ofil/'p099105a.10'/,
     $       iavt/54000*0/, sfile/'p099105.dat'/,cr1/'a'/
        data edepfile/'edeps-old'/
        data edepfilenew/'p210704a-edep'/
!
        open(33,file='find-e-dep.log',status='unknown',form='formatted')
c prompt op for input
	write(*,*)' Enter cruise name:  (ie. p099105a) '
	read(5,'(a8)') cr
	write(*,*)' Include t5s in processing?  (y or n)'
	read(5,'(a1)') ans
        
        write(33,*)'cr=',cr(1:8)
        if(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09'.or.cr(1:3).eq.'p13')then
           edepfile(5:5) = cr(8:8)
           open(37,file=edepfile,form='formatted',status='unknown')
        elseif(cr(2:3).eq.'15'.or.cr(2:3).eq.'21') then
           edepfilenew(1:8) = cr(1:8)
           open(37,file=edepfilenew,form='formatted',status='unknown')
        else
           open(37,file=edepfile,form='formatted',status='unknown')
        endif
!
        ofil(1:8)=cr(1:8)
        efile(1:7)=cr(1:7)
        t5e(4:10) = cr(1:7)
        nsta=0
        sfile(1:7) = cr(1:7)
!
        if(cr(1:3).eq.'p31') then
! look at xbtinfo.p31 to sort into the 4 diff tracks:
          open(15,file='/data/xbt/xbtinfo.p31',status='old',
     $         form='formatted')
! skip 3 lines header:
          read(15,*)
          read(15,*)
          read(15,*)
! 9may2013 LL duh, increase loop here, xbtinfo.p31 was > 100 (old loop size)
          do 1 iz = 1, 500
             read(15,'(a4,25x,i1)') c,i
                write(33,*) c(1:4),cr(4:7), i
                call flush(33)
             if(c(1:4).eq.cr(4:7)) then
                if(i.eq.1) atrack = 'A'
                if(i.eq.2) atrack = 'B'
                if(i.eq.3) atrack = 'C'
                if(i.eq.4) atrack = 'D'
                if(i.eq.5) atrack = 'E'
                write(33,*) c(1:4),cr(4:7), i, atrack
                go to 2
             endif
1         continue
2         continue
          close(15)
          write(33,*)'atrack=',atrack
! end p31
        elseif(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09') then
! look at p06XXXX{a,b,c}.10 to determine which track to create edep{a,b,c}-old
           open(47,file=ofil,status='old',form='formatted')
           read(47,'(i4)')nsta
           do 60 i=1,nsta
! idn is drop numbers inside of a or b or c
              read(47,'(37x,i3)')idn(i)
              do 59 j = 1, 8
59            read(47,*)        ! skip 8 lines of data
60         continue
           close(47)
        endif ! p06/p09
!
        iaddnoumea = 0
! open "stations.dat" file (appropriately named for cruise (eg p311005.dat))
        open(7,file=sfile,status='old',form='formatted')
        do 22 ii=1,1000
           read(7,500,end=100)dropno,d(1:17),xlt,xln,iedt
500        format(1x,a3,14x,a17,2f9.3,7x,i2)
           if(dropno(1:3).eq.'NDD') go to 100
           read(dropno,'(i3)') j
! if it's p06 - see if it's in our a b or c:
           if(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09') then
              do 42 kk = 1, nsta
                 if(j.eq.idn(kk)) go to 43  ! use it
42            continue
              go to 20 ! skip it
           endif
43         continue
! skip if iedt=-1 or -2:
           if(iedt.eq.-1.or.iedt.eq.-2.or.iedt.eq.-4.or.iedt.eq.-6)then
              write(*,*)'iedt = ',iedt, ' skipping ', dropno
              go to 20
           endif
! skip if op says not to include t5's in processing:
           if(iedt.eq.2.and.ans(1:1).eq.'n') then
              write(*,*)'iedt=2 (t5) you do not want t5s, skipping', dropno
              go to 20
           endif
! watch iuse here. 5may2012 it appears to be:
! iuse = 0 for deep defined ranges - appends -R for mkcruisebath to deal with
! iuse = 1 for cruises without deep defined ranges 
           iuse = 1
           if(cr(1:3).eq.'p05'.or.cr(1:3).eq.'p31') then
              iuse = 0
           endif
           write(*,*) 'iuse=', iuse, ' !!!! '
!           write(*,*) 'SKIPPING P31 range check!'
!           go to 456
! if p31, check longitude range (using atrack!) to determine using if use e file dep or 800m:
           if(cr(1:3).eq.'p31'.and.ii.gt.1) then
! also check if need to add 0 depth for noumea:
              if((atrack.eq.'A'.or.atrack.eq.'B')
     $            .and.iaddnoumea.eq.0) then
! which direction are we going:
                 if(xlnprev.lt.xln) then
! left to right (low long to high long):
                    if(xln.gt.166.75) then
                       write(37,568) 166.75,xlt-0.05,0.0,'ADD  ',dropno
                       iaddnoumea = 1
                    endif
                 elseif(xlnprev.gt.xln) then
! right to left (high long to low long):
                    if(xln.lt.166.75) then
                       write(37,568) 166.75,xlt+0.05,0.0,'ADD  ',dropno
                       iaddnoumea = 1
                    endif
                 endif
              endif
              call checktrackpos(cr,xln,xlt,atrack,iuse)
              write(33,*) xln,xlt,atrack,iuse
! on return from checktrackpos, if iuse=0=800m, iuse=1=xbt depth
!              if(iuse.eq.0) then
!29nov2010LL no- write depth                 write(37,568) xln, xlt, xlev0, 'RANGE' ,dropno
!                 go to 20
!              endif
           elseif(cr(1:3).eq.'p05'.and.ii.gt.1) then
              atrack = 'A'
              call checktrackpos(cr,xln,xlt,atrack,iuse)
           endif
! endif for p31 & p05 mods
456        continue
!
           nbin=0
           ibins=0
           write(efile(10:12),'(a3)') dropno
           write(*,*)'opening ', efile
           open(8,file=efile,status='old',err=15,form='formatted')
! skip 1st 2 lines of e file
           read(8,*)
           read(8,*)

! increase from 450 to 500:
           do 30 k=1,500
              read(8,'(a14)',end=21,err=21) chr14
              if(chr14(13:14).eq.'HB'.and.chr14(11:11).eq.'3') then
                 read(chr14,*,end=21,err=21)idep,item
                 xdep = -1.0*real(idep)
                 if(iuse.eq.0) then
                    write(37,568) xln, xlt, xdep,  'HBR-R',dropno
                 else
                    write(37,568) xln, xlt, xdep,  'HBR  ',dropno
                 endif
                 go to 20
              elseif(chr14(11:11).eq.'5') then
! 15apr2013 LL duh, skip interpolations!
                 go to 30
! WB or else, mark no value and use SnS
              elseif(chr14(11:11).ge.'3') then
                 read(chr14,*,end=21,err=21)idep,item
                 xdep = -1.0*real(idep)
                 if(iuse.eq.0) then
                    write(37,568) xln, xlt, (xdep+2.0),  'C34-R' ,dropno
                 else
                    write(37,568) xln, xlt, (xdep+2.0),  'C34  ' ,dropno
                 endif
                 go to 20
! Ann Gronell case, I assume HB in the datn file means it's a HB, but the
! last data point in file is good, so, do HB? and add 2m.
              elseif(chr14(13:14).eq.'HB'.and.chr14(11:11).eq.'2') then
                 read(chr14,*,end=21,err=21)idep,item
                 xdep = -1.0*real(idep+2)
                 if(iuse.eq.0) then
                    write(37,568) xln, xlt, xdep,  'HB -R' ,dropno
                 else
                    write(37,568) xln, xlt, xdep,  'HB   ' ,dropno
                 endif
                 go to 20
              endif
30         continue
21         close(8)
! 14may2012 LL for AG case of only C1 and C2 data in file:
           if(chr14(11:11).eq.'1') then
              read(chr14,*,end=21,err=21)idep,item
              xdep = -1.0*real(idep+2)
              if(iuse.eq.0) then
                 write(37,568) xln, xlt, xdep,'C12-R',dropno
              else
                 write(37,568) xln, xlt, xdep,'C12  ',dropno
              endif
           else
! if no HB or class ge 3, then just write last recorded depth of e file:
           read(chr14,*,end=21,err=21)idep,item
           xdep = -1.0*real(idep)
           if(iuse.eq.0) then
           write(37,568) xln, xlt, xdep,'LST-R',dropno
           else
           write(37,568) xln, xlt, xdep,'LST  ',dropno
           endif
           endif

568        format(2f8.3,f8.0,1x,a5,1x,a3)
!
15      continue
20      continue
        xlnprev = xln
        xltprev = xlt
22      continue

        stop
25      write(*,*)' You said to include t5 e files in processing, but'
        write(*,*)' I cannot find ', dropno ,' in either the main dir'
        write(*,*)' or the t5 dir'
        write(*,*)
        write(*,*)' Output written to tenm3.log '
100     continue
        stop
      end
! --------------------------------------
      subroutine checktrackpos(cr,xln,xlt,atrack,iuse)
      character*1 atrack, cr*8
! set iuse = 0 = 800m
!     iuse = 1 = xbt depth
!
      iuse = 0
! PX31 begin:
      if(cr(1:3).eq.'p31') then
! B-N-L
      if(atrack.eq.'A') then
         if(xln.le.153.82) then
            iuse = 1
         elseif(xln.ge.159.461.and.xln.le.159.80) then
            iuse = 1
! not sure about this one:
         elseif(xln.ge.166.216.and.xln.le.167.50) then
            iuse = 1
         elseif(xln.ge.177.166) then
            iuse = 1
         endif
! B-N-S
      elseif(atrack.eq.'B') then
         if(xln.le.153.82) then
            iuse = 1
         elseif(xln.ge.159.461.and.xln.le.159.80) then
            iuse = 1
         elseif(xln.ge.166.216.and.xln.le.167.50) then
            iuse = 1
         elseif(xln.ge.178.381) then
            iuse = 1
         endif
! B-L
      elseif(atrack.eq.'C') then
         if(xln.le.153.81) then
            iuse = 1
         elseif(xln.ge.159.461.and.xln.le.159.84) then
            iuse = 1
         elseif(xln.ge.166.961.and.xln.le.168.97) then
            iuse = 1
         elseif(xln.ge.177.166) then
            iuse = 1
         endif
! B-S
      elseif(atrack.eq.'D') then
         if(xln.le.153.81) then
            iuse = 1
         elseif(xln.ge.159.496.and.xln.le.159.84) then
            iuse = 1
         elseif(xln.ge.166.961.and.xln.le.168.983) then
            iuse = 1
         elseif(xln.ge.171.631.and.xln.le.171.634) then
            iuse = 1
         elseif(xln.ge.178.000) then
            iuse = 1
         endif
! B-V
      elseif(atrack.eq.'E') then
         if(xln.le.153.81) then
            iuse = 1
         elseif(xln.ge.159.461.and.xln.le.159.84) then
            iuse = 1
         elseif(xln.ge.166.961.and.xln.le.168.97) then
            iuse = 1
         elseif(xln.ge.179.190) then
            iuse = 1
         endif

      endif
! PX31 end 
!begin PX05 range check
      elseif(cr(1:3).eq.'p05') then
         if(xlt.le.-25.151) then
            iuse = 1
         elseif(xlt.ge.-23.397.and.xlt.le.-21.746) then
            iuse = 1
         elseif(xlt.ge.33.303.and.xlt.le.33.937) then
            iuse = 1
         elseif(xlt.ge.34.777) then
            iuse = 1
         endif
      endif
 
      return
      end
 

