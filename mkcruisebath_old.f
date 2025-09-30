       program mkcruisebath
!14mar2019 LL exit gracefully if stations.dat has ENDDATA
! 07nov2012 LL - p37 - my re-edits have not been processed, so
! e's/p*dat/stations.dat/*a.10 are a bit messy. Do not reprocess
! yet - since file will not match (.10 .10s .10s_argo etc)
! just wing it in here....

! 20jun2012 LL p15 lines read <cruise>-edep not edepX-old...
!---------------------------------
!4may2012 LL try to fix the no -R choices:
! For NO -R (no deep defined range)
! If xbt is HBR then that's the depth
! If xbt is C34 and XBT depth is < 800, then check SnS:
!      If SnS < 800m, use SnS depth
!      If SnS >= 800m, use 800m
! If xbt is C34 and XBT depth is >= 800, use 800m
!---------------------------------
! 4may2012 LL add i15/p15/i21/etc
! try to create a bathXX.dat file for each cruise using
! smith and sandwell bathy and lat, lon of drops:
! nblat, nblon - number of lats/longs in sns file
        parameter(nblonmax=7400)
        parameter(nblatmax=5700)

       parameter(nposmax=999)
       dimension snslon(nblonmax)
       dimension snslat(nblatmax)
       dimension snsbath(nblonmax,nblatmax)
       dimension snslon2(nblonmax)
       dimension snslat2(nblatmax)
       dimension snsbath2(nblonmax,nblatmax)
       dimension ypos(nposmax)
       dimension xpos(nposmax)
       dimension bath(nposmax)
       dimension bathave(nposmax)
       dimension edep(nposmax), it(100)
       dimension sns(4)
       dimension idn(400)
       character *8 cr, lcode*5, arange*1
       character*11 cruise
       character*13 edepfilenew
       character*9 edepfile
       character*9 bathfile
       character*13 bathfilenew
       character*31 bathname, c*4, atrack*1
       character*31 bathname2
       character*11 ofil
       character*3 dropno
       integer ios
!MB       character*16 bathname, c*4, atrack*1
       data cruise/'p340811.dat'/
! Nathalie Zilberman multibeam:
!MB       data bathname/'../topo_PX30.tx2'/
!       data bathname/'../px31-sns-bath.cgi'/
!       data bathname/'../ps37-sns-bath.cgi'/
       data edepfile/'edeps-old'/
       data edepfilenew/'p210704a-edep'/
!                        0123456789012       
       data bathfile/'bath1.dat'/
!                     012345678
       data bathfilenew/'p210704a-bath'/
!                        0123456789012
       data ofil/'p060907c.10'/
!                 01234567890
       data bathname/'/data/xbt/p05/px05-sns-bath.cgi'/
!                     1234567890123456789012345678901
       data bathname2/'/data/xbt/p06/px06-sns-bath.cgi'/
!                      1234567890123456789012345678901
!
       deg2rad = 0.0174444
       write(*,*) 'enter cruise name: (p340811a)'
       read(5,'(a8)') cr
       ofil(1:8) = cr(1:8)
       cruise(1:7) = cr(1:7)
! bathname name:
       bathname(11:13) = cruise(1:3)
       bathname(17:18) = cruise(2:3)
       if(cruise(1:3).eq.'s37') then
          bathname(16:16) = cruise(1:1)
       endif
       if(cruise(1:3).eq.'p40') then
          bathname(11:13) = 'p37'
          bathname(17:18) = '37'
       endif
       if(cruise(1:3).eq.'p44') then
          bathname(11:13) = 'p37'
          bathname(17:18) = '37'
       endif
       if(cruise(1:3).eq.'p13') then
          bathname(11:13) = 'p09'
          bathname(17:18) = '09'
       endif
       if(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09'.or.cr(1:3).eq.'p13')then
          edepfile(5:5) = cr(8:8)
          bathfile(5:5) = cr(8:8)
          write(*,*)'opening edepfile=', edepfile
          open(25,file=edepfile,status='old',form='formatted',err=2)
          write(*,*)'opening bathfile=', bathfile
          open(30,file=bathfile,status='unknown',form='formatted')
       elseif(cr(2:3).eq.'15'.or.cr(2:3).eq.'21') then
!16jul2013 change bath1.dat to batha.dat:
          bathfile(5:5) = cr(8:8)
          edepfilenew(1:8) = cr(1:8)
          bathfilenew(1:8) = cr(1:8)
          open(25,file=edepfilenew,status='old',form='formatted',err=2)
!fails:          open(30,file=bathfilenew,status='unknown',form='formatted')
          open(30,file=bathfile,status='unknown',form='formatted')
       else
          open(25,file=edepfile,status='old',form='formatted',err=2)
          open(30,file=bathfile,status='unknown',form='formatted')
       endif
       if(cruise(1:3).eq.'a07'.or.
     $    cruise(1:3).eq.'a08'.or.
     $    cruise(1:3).eq.'a10'.or.
     $    cruise(1:3).eq.'a18'.or.
     $    cruise(1:3).eq.'a97') then
          bathname(15:15) = 'a'
          bathname(11:13) = 'a08'
          bathname(17:18) = '08'
       endif
! dimensions:
!
! flag if need to open second bath for p09/p06
       iaddp06 = 0
       if(cruise(1:3).eq.'p34') then
! p34 old  nblat=543, nblon=1501
! p34 31may2012 nblat=704, nblon=1507
          nblat=704
          nblon=1507
       elseif(cruise(1:3).eq.'s37') then
! p37s nblat=848, nblon=2401
          nblat=848
          nblon=2401
       elseif(cruise(1:3).eq.'p05') then
!px05-all
          nblat=3912
          nblon=904
       elseif(cruise(1:3).eq.'p50') then
          nblat=3471
          nblon=6947
!px06 loop
       elseif(cruise(1:3).eq.'p06') then
          nblat=1384     ! pre 21mar2019 was =1219
          nblon=2935     ! pre 21mar2019 was = 739
       elseif(cruise(1:3).eq.'p31') then
!SnSpx31
          nblat=637
          nblon=1524
       elseif(cruise(2:3).eq.'15'.or.cruise(2:3).eq.'21') then 
!SnS ix15 (southern Indian Ocean area)
          nblat=2718
          nblon=7195
          bathname(12:13) = '15'
          bathname(15:18) = 'ix15'
       elseif(cruise(1:3).eq.'p37') then
          nblat=1629
          nblon=7310
       elseif(cruise(1:3).eq.'p40') then
          nblat=1629
          nblon=7310
       elseif(cruise(1:3).eq.'p44') then
          nblat=1629
          nblon=7310
       elseif(cruise(1:3).eq.'p38') then
          nblat=3450
          nblon=1423
       elseif(cruise(1:3).eq.'a07'.or.
     $    cruise(1:3).eq.'a08'.or.
     $    cruise(1:3).eq.'a10'.or.
     $    cruise(1:3).eq.'a18'.or.
     $    cruise(1:3).eq.'a97') then
          nblat=5655
          nblon=5950
       elseif(cruise(1:3).eq.'p09'.or.cruise(1:3).eq.'p13') then
! how to handle p09 with p06?
          nblat=4403
          nblon=3841        ! pre 21mar2019 was = 3817
! well, just open px06 as a second file...
          iaddp06 = 1
          write(*,*)'opening bathname2: ', bathname2
          open(unit=12,file=bathname2,status='old',iostat=ios)
          nblat2=1384     ! pre 21mar2019 was =1219
          nblon2=2935     ! pre 21mar2019 was = 739
          do 55 i = 1, nblat2
          do 55 j = 1, nblon2
             read(12,500,end=777,err=777) snslon2(j),snslat2(i),
     $                                    snsbath2(j,i)
55        continue
          close(12)
       else
          stop 'need SnS file for this cruise'
       endif
       if(nblat.gt.nblatmax) stop 'redimension nblatmax'
       if(nblon.gt.nblonmax) stop 'redimension nblonmax'
! multibeam:
!MB       nblat=371
!MB       nblon=740
!
       atrack = 'A'
       if(cr(1:3).eq.'p31') then
! look at xbtinfo.p31 to sort into the 4 diff tracks:
        open(15,file='/data/xbt/xbtinfo.p31',status='old',
     $         form='formatted')
! skip 3 lines header:
        read(15,*)
        read(15,*)
        read(15,*)
        do 1 iz = 1, 100
          read(15,'(a4,25x,i1)') c,i
          if(c(1:4).eq.cruise(4:7)) then
             if(i.eq.1) atrack = 'A'
             if(i.eq.2) atrack = 'B'
             if(i.eq.3) atrack = 'C'
             if(i.eq.4) atrack = 'D'
             if(i.eq.5) atrack = 'E'
             go to 22
          endif
1       continue
22      continue
       
        close(15)
! end p31
        elseif(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09'.or.cr(1:3).eq.'p13')
     $  then
! look at p06XXXX{a,b,c}.10 to determine which track to create
           write(*,*)'opening ofil =',ofil
           open(47,file=ofil,status='old',form='formatted')
           read(47,'(i4)')nsta
           write(*,*)'nsta in ', ofil,' =',nsta
           do 60 i=1,nsta
! idn is drop numbers inside of a or b or c
              read(47,'(37x,i3)')idn(i)
              do 59 j = 1, 8
59            read(47,*)        ! skip 8 lines of data
60         continue
           close(47)
        endif ! p06

       write(*,*)'opening ', bathname
       open(10,file=bathname,status='old',form='formatted',err=778)
       write(*,*)'opening ', cruise
       open(20,file=cruise,status='old',form='formatted',err=779)
       open(33,file='errorSnS',status='unknown',form='formatted')
       open(35,file='../e-sns.txt',status='unknown',
     $         access='append',form='formatted')

! iedep=1, edeps-old exists, iedep=0 no exist
       iedep = 1
       go to 3
2      iedep=0
3      continue
!SnS:
       do 5 i = 1, nblat
       do 5 j = 1, nblon
          read(10,500,end=777,err=777) snslon(j),snslat(i),snsbath(j,i)
500       format(2f9.4,f10.2)
5      continue
       close(10)
       write(*,*)'finish reading file ', bathname
!
       npos = 0
       write(30,510) 
510    format(' long    lat      final     SnS       E   code')
! loop through local p09XXXX.dat (stations.dat)
       do 50 k = 1, 1000
!debug       do 50 k = 1, 3
7         read(20,520,end=12,err=12) dropno,yp, xp, iedt
520       format(1x,a3,32x,f8.3,1x,f8.3,7x,i2)
          if(dropno(1:3).eq.'NDD') go to 12
          read(dropno,'(i3)') j
          write(*,*)'cruise=',cruise,'dropno=',dropno
! if it's p06 - see if it's in our a b or c:
           if(cr(1:3).eq.'p06'.or.cr(1:3).eq.'p09'.or.cr(1:3).eq.'p13') 
     $       then
              do 42 kk = 1, nsta
                 if(j.eq.idn(kk)) go to 43  ! use it
42            continue
              go to 7 ! skip it
           endif
43         continue
! skip dup longs in px31...
!          if(cr(2:3).eq.'31'.and.xp.eq.xpos(k-1)) go to 7
!          if(yp.eq.0.0.or.xp.eq.0.0) go to 7
! well, ok, skip iedt = -1 or -2 instead...
          if(iedt.eq.-1.or.iedt.eq.-4.or.iedt.eq.-2.or.iedt.eq.-6)
     $         go to 7
          write(*,*) 'iedt=',iedt
! skip t5's too: 22aug2012
! 04dec2012 - p34 uses 2 also...
! 24sep2012 - p31 uses 2, so do not skip (what will this mess up?)
! 07nov2012 screws up p37 pretty well, so skip iedt=2 for all but p31?
! argh 25jan2012 add atlantic here too
          if((cr(1:3).ne.'p31'.and.cr(1:3).ne.'p34'.and.
     $        cr(1:1).ne.'a').and.iedt.eq.2) 
     $             go to 7
          ypos(k) = yp
          xpos(k) = xp
          write(*,*)'iedep=',iedep
! read edeps file (created by find-e-dep.f)
          if(iedep.eq.1) then
88           read(25,521,end=12,err=12) xpos1,ypos1, edep(k), lcode
             write(*,*) 'edep:',xpos1,ypos1, edep(k), lcode
             if(lcode(1:3).eq.'ADD') then
                write(30,504)xpos1,ypos1,edep(k),edep(k),edep(k),
     $                       lcode, edep(k)
                go to 88
             endif
             if(ypos(k).ne.ypos1) then
                write(*,*)  ypos(k),ypos1, iedt,dropno,yp,xp
                stop 'check positions between p*.dat and deps'
             endif
! if no edeps file, then set edep = 999.0 (no value)
          elseif(iedep.eq.0) then
             edep(k) = 999.0
             lcode(1:2) = 'no'
          endif
          npos = npos + 1
!!!!!!521       format(f8.3,f8.0,1x,a3)
521       format(2f8.3,f8.0,1x,a5)
!-----------------------------------------------------------------------
! 10may2012 LL ok, if it's p09, check if we're in px06 area and use
!   that cgi file instead. Convoluted, yes.
          if(iaddp06.eq.0.or.
     $      (iaddp06.eq.1.and.ypos(k).ge.-17.8934)) then
! regular:
          ilat = 0
          ilon = 0
! find sns surrounding latitude:
          do 40 i = 1, nblat-1
             if(ypos(k).le.snslat(i).and.ypos(k).ge.snslat(i+1)) then
                ilat = i 
                go to 41
             endif
40        continue
41        continue
! find sns surrounding longitude:
          do 45 j = 1, nblon-1
             if(xpos(k).ge.snslon(j).and.xpos(k).le.snslon(j+1)) then
                ilon = j 
                go to 46
             endif
45        continue
46        continue
       write(33,*) 'after 46: '
       write(33,*) 'xbt lat,lon=',ypos(k), xpos(k)
       write(33,*) 'ilat,ilon ', ilat,ilon
       if(ilat.eq.0.or.ilon.eq.0) then
          bath(k) = 999.0
          sns(1) = 999.0
          sns(2) = 999.0 
          sns(3) = 999.0 
          sns(4) = 999.0        
          go to 121
       endif
       call flush(33)
! check that I have enough positions in SnS file:
       if(ilon+1.gt.nblon) stop ' AA need more longs in SnS'
       if(ilat+1.gt.nblat) stop ' AA need more lats in SnS'
! calculate the 4 distances:
! 1: ilat,ilon:
       avlat=(snslat(ilat)+ypos(k))/2.
       dist1=sqrt((snslat(ilat)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon(ilon)-xpos(k)))**2)
! 2: ilat,ilon+1:
       avlat=(snslat(ilat)+ypos(k))/2.
       dist2=sqrt((snslat(ilat)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon(ilon+1)-xpos(k)))**2)
! 3: ilat+1,ilon+1:
       avlat=(snslat(ilat+1)+ypos(k))/2.
       dist3=sqrt((snslat(ilat+1)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon(ilon+1)-xpos(k)))**2)
! 4: ilat+1,ilon:
       avlat=(snslat(ilat+1)+ypos(k))/2.
       dist4=sqrt((snslat(ilat+1)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon(ilon)-xpos(k)))**2)

      write(33,*) snslat(ilat), snslon(ilon), snsbath(ilon,ilat)
      call flush(33)
      write(33,*) 'dist1: ',dist1
      write(33,*) snslat(ilat), snslon(ilon+1), snsbath(ilon+1,ilat)
      write(33,*) 'dist2: ',dist2
      write(33,*) snslat(ilat+1), snslon(ilon+1), snsbath(ilon+1,ilat+1)
      write(33,*) 'dist3: ',dist3
      write(33,*) snslat(ilat+1), snslon(ilon), snsbath(ilon,ilat+1)
      write(33,*) 'dist4: ',dist4
      call flush(33)
! if any of the dist{1-4}=0.0, then xbt position is identical to that
! SnS lat, lon, so use it's snsbath
      if(dist1.eq.0.0) then
         bath(k) = snsbath(ilon,ilat) 
      elseif(dist2.eq.0.0) then
         bath(k) = snsbath(ilon+1,ilat) 
      elseif(dist3.eq.0.0) then
         bath(k) = snsbath(ilon+1,ilat+1) 
      elseif(dist4.eq.0.0) then
         bath(k) = snsbath(ilon,ilat+1) 
      else
! do the weighted average thing:
! square them, then 1/x:
         d1 = 1.0/dist1**2
         d2 = 1.0/dist2**2
         d3 = 1.0/dist3**2
         d4 = 1.0/dist4**2
         xnorm = d1+d2+d3+d4
! get the weighted multiplier:
         x1 = d1/xnorm
         x2 = d2/xnorm
         x3 = d3/xnorm
         x4 = d4/xnorm
         write(33,*) 'mults:',x1,x2,x3,x4
! final bath = 
         bath(k) = snsbath(ilon,ilat)* x1 + 
     $       snsbath(ilon+1,ilat)* x2 + 
     $       snsbath(ilon+1,ilat+1)* x3 + 
     $       snsbath(ilon,ilat+1)* x4
      endif
      bathave(k) = bath(k)
! get the SnS min and max values:
      sns(1) = snsbath(ilon,ilat)
      sns(2) = snsbath(ilon+1,ilat)
      sns(3) = snsbath(ilon+1,ilat+1)
      sns(4) = snsbath(ilon,ilat+1)
      else
! this is for p09 cruises in p06 area: 
! find sns surrounding latitude:
          do 440 i = 1, nblat2-1
             if(ypos(k).le.snslat2(i).and.ypos(k).ge.snslat2(i+1)) then
                ilat = i
                go to 441
             endif
440        continue
441        continue
! find sns surrounding longitude:
          do 445 j = 1, nblon2-1
             if(xpos(k).ge.snslon2(j).and.xpos(k).le.snslon2(j+1)) then
                ilon = j
                go to 446
             endif
445        continue
446        continue
       write(*,*) 'after 446, ', ypos(k), xpos(k)
       write(*,*)'ilon=', ilon
       write(*,*)'nblon2=', nblon2
       call flush(33)
! check that I have enough positions in SnS file:
       if(ilon+1.gt.nblon2) stop ' BB need more longs in SnS'
       if(ilat+1.gt.nblat2) stop ' BB need more lats in SnS'
! calculate the 4 distances:
! 1: ilat,ilon:
       avlat=(snslat2(ilat)+ypos(k))/2.
       dist1=sqrt((snslat2(ilat)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon2(ilon)-xpos(k)))**2)
! 2: ilat,ilon+1:
       avlat=(snslat2(ilat)+ypos(k))/2.
       dist2=sqrt((snslat2(ilat)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon2(ilon+1)-xpos(k)))**2)
! 3: ilat+1,ilon+1:
       avlat=(snslat2(ilat+1)+ypos(k))/2.
       dist3=sqrt((snslat2(ilat+1)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon2(ilon+1)-xpos(k)))**2)
! 4: ilat+1,ilon:
       avlat=(snslat2(ilat+1)+ypos(k))/2.
       dist4=sqrt((snslat2(ilat+1)-ypos(k))**2+
     $(cos(avlat*deg2rad)*(snslon2(ilon)-xpos(k)))**2)
      write(33,*) 'ilat,ilon ', ilat,ilon
      write(33,*) snslat2(ilat), snslon2(ilon), snsbath2(ilon,ilat)
      write(33,*) 'dist1: ',dist1
      write(33,*) snslat2(ilat), snslon2(ilon+1), snsbath2(ilon+1,ilat)
      write(33,*) 'dist2: ',dist2
      write(33,*) snslat2(ilat+1), snslon2(ilon+1), 
     $             snsbath2(ilon+1,ilat+1)
      write(33,*) 'dist3: ',dist3
      write(33,*) snslat2(ilat+1), snslon2(ilon), snsbath2(ilon,ilat+1)
      write(33,*) 'dist4: ',dist4
! if any of the dist{1-4}=0.0, then xbt position is identical to that
! SnS lat, lon, so use it's snsbath
      if(dist1.eq.0.0) then
         bath(k) = snsbath(ilon,ilat)
      elseif(dist2.eq.0.0) then
         bath(k) = snsbath(ilon+1,ilat)
      elseif(dist3.eq.0.0) then
         bath(k) = snsbath(ilon+1,ilat+1)
      elseif(dist4.eq.0.0) then
         bath(k) = snsbath(ilon,ilat+1)
      else
! do the weighted average thing:
! square them, then 1/x:
         d1 = 1.0/dist1**2
         d2 = 1.0/dist2**2
         d3 = 1.0/dist3**2
         d4 = 1.0/dist4**2
         xnorm = d1+d2+d3+d4
! get the weighted multiplier:
         x1 = d1/xnorm
         x2 = d2/xnorm
         x3 = d3/xnorm
         x4 = d4/xnorm
         write(33,*) 'mults:',x1,x2,x3,x4
! final bath = 
         bath(k) = snsbath2(ilon,ilat)* x1 +
     $       snsbath2(ilon+1,ilat)* x2 +
     $       snsbath2(ilon+1,ilat+1)* x3 +
     $       snsbath2(ilon,ilat+1)* x4
      endif
      bathave(k) = bath(k)
! get the SnS min and max values:
      sns(1) = snsbath2(ilon,ilat)
      sns(2) = snsbath2(ilon+1,ilat)
      sns(3) = snsbath2(ilon+1,ilat+1)
      sns(4) = snsbath2(ilon,ilat+1)
      endif ! end of p06 area inside p09

!------------------------------------------------------------------

      limit = 4
111   if(limit.le.1) go to 121
      last = 0
      do 30 i = 1, limit-1
         if(sns(i).le.sns(i+1)) go to 20
         temp = sns(i)
         sns(i) = sns(i+1)
         sns(i+1) = temp
         last = i
20       continue
30    continue
      limit = last
      go to 111
121   continue
      write(33,*) 'sns= ', bath(k), '  edep= ', edep(k)
      write(33,*) sns(1), sns(2), sns(3), sns(4)        
 
      bathsave = bath(k)
! is edep(k) inside the SnS "range" of 4 surrounding values?:
      arange = 'N'
      if(edep(k).ne.999.0) then
         if(edep(k).ge.sns(1).and.edep(k).le.sns(4)) arange = 'Y'
      endif
! compare to matching e file depth:
! no e file for a depth, use sns:
       if(edep(k).eq.999.0) then
          write(33,*)'no edep'
          go to 49
!
! add 5may2012 LL:
! HB is always the bottom:
       elseif(lcode(1:2).eq.'HB') then
          bath(k) = edep(k)
          bathave(k) = edep(k)
          write(35,524)cruise(4:7),xpos(k),ypos(k),bathsave,
     $      edep(k),lcode,sns(1),sns(2),sns(3),sns(4),
     $       bathsave-edep(k),arange,atrack
! no HB, so it's a break:
! 7may2012 LL try 'LST' here too:
       elseif(lcode(1:3).eq.'C34'.or.lcode(1:3).eq.'LST'.or.
     $        lcode(1:3).eq.'C12') then
! recall gt -800 means shallower than 800m
          if(edep(k).gt.-800.0) then
             if(bath(k).gt.-800.0) then
! want edep if edep is deeper than Sns bath:
                if(edep(k).lt.bath(k)) then
                   bath(k) = edep(k)
                   bathave(k) = edep(k)
                endif
! here's the confusing one:
! e depth is shallower than SnS bath, if it's LST then there
!  are no HB marks in this cruise yet (old data) so set bath = edep.
!  if it's C34 then it's a wire break and probably safe to use SnS
                if(edep(k).gt.bath(k)) then
                  if(lcode(1:3).eq.'LST') then
                      bath(k) = edep(k)
                      bathave(k) = edep(k)
                  elseif(lcode(1:3).eq.'C34'.or.lcode(1:3).eq.'C12')then
!                     no change bath=bath
                  endif
                endif
!               no change, use SnS bath() calculated above
! lt -800 means SnS is deeper than 800 m:
             elseif(bath(k).le.-800.0) then
                bath(k) = -800.0
                bathave(k) = bathsave
             endif
! here we have edep is deeper than 800m:
          elseif(edep(k).le.-800.0) then
             bath(k) = -800.0
!            this one means edep is deeper than SnS:
             if(edep(k).lt.bathsave) then
                bathave(k) = edep(k) 
             else
                bathave(k) = bathsave
             endif
          endif
! end add 5may2012 LL
!
! use e file depth IF e deeper than sns depth:  recall negative depths...
       elseif(edep(k).lt.bath(k)) then
          write(33,*)'change bath(k) to ', edep(k)
          bath(k) = edep(k)
          bathave(k) = edep(k)
          call flush(33)
          write(35,524)cruise(4:7),xpos(k),ypos(k),bathsave,
     $      edep(k),lcode,sns(1),sns(2),sns(3),sns(4),
     $       bathsave-edep(k),arange,atrack
          write(33,*)'finish writing 35'
          call flush(33)
524    format(a4,2f8.3,1x,f6.0,1x,f6.0,1x,a3,1x,5(f6.0),1x,a1,1x,a1)
! if e file shallower than sns - it still could be a better estimate -
! ok 6oct2010 - start using 'HB' IF they exist.   If e shallower than
! SnS AND HB, then that's the bottom.   
! If e shallower than SnS and NO HB recorded, then use SnS.   eek.
!  |--->>> 3jan2011 no, if e shallower than Sns AND NO HB recorded AND
!                       we are in possible shallow water, use e depth
       elseif(edep(k).gt.bath(k)) then
          if(lcode(1:2).eq.'HB') then
             write(33,*)k, ' HB: change bath(k) to ', edep(k),
     $                  ' from ', bath(k)
             bath(k) = edep(k)
             bathave(k) = edep(k)
             if(edep(k).gt.-800.0) then
               write(35,524)cruise(4:7),xpos(k),ypos(k),bathsave,
     $         edep(k),lcode,sns(1),sns(2),sns(3),sns(4),
     $         bathsave-edep(k),arange,atrack
             endif
! p31 if in -R (Deep range) then use SnS (well, -800 really, but I'd like all depths.)
          elseif(lcode(4:5).eq.'-R') then
             write(33,*)k, ' -R: change bath(k) to '
             bath(k) = -800.0
             bathave(k) = bathsave
!          elseif(cruise(1:3).eq.'p31'.and.lcode(4:5).eq.'  ') then
! do for all cruises?  (3jan2011)
          elseif(lcode(4:5).eq.'  ') then
             write(33,*)k, ' NO -R: change bath(k) to ', edep(k)
             bath(k) = edep(k)
             bathave(k) = edep(k)
! 30mar2012 LL well, want bath=-800 IF edep deeper than -800, I think
             if(bath(k).lt.-800.0) then
                bath(k) = -800.0
                bathave(k) = bathsave
             endif
          else
!            Leave bath(k) as sns, no change here
          if(edep(k).gt.-800.0) then
          write(35,524)cruise(4:7),xpos(k),ypos(k),bathsave,
     $      edep(k),lcode,sns(1),sns(2),sns(3),sns(4),
     $       bathsave-edep(k),arange,atrack
          endif
          endif
       endif
49     continue
       write(33,*) ' ', bath(k)
       write(30,504)xpos(k),ypos(k),bath(k), bathsave,edep(k),lcode,
     $              bathave(k)
504    format(2f8.3,f8.0,1x,f8.0,1x,f8.0,1x,a5,1x,f8.0)
50     continue
12     continue
! write it out:
!       write(30,*) npos
! want to write from lowest to highest lat:
!       if(ypos(1).lt.ypos(npos)) then
!       print *, 'a'
!        do 60 k = 1, npos
!           write(30,503) ypos(k), bath(k)
!60      continue 
!       else
!        do 63 k = npos, 1, -1
!           write(30,503) ypos(k), bath(k)
!63      continue 
!       endif
! want to write from lowest to highest long:
!       if(xpos(1).lt.xpos(npos)) then
!       print *, 'a'
!        do 60 k = 1, npos
!           write(30,503) xpos(k), bath(k)
!60      continue 
!       else
!        do 63 k = npos, 1, -1
!           write(30,503) xpos(k), bath(k)
!63      continue 
!       endif
503    format(f8.3,f8.0)

       go to 800
777    stop ' end cgi file'
778    stop ' error opening bathname'
779    stop ' error opening cruise'

800    continue
       stop
       end
