!22apr2009 modify rdxbtinfo1 to grab track only (for gvdel98)
        subroutine rdxbtinfo2(xbtinfo,cruise,iport)
c	INPUT: xbtinfo(1:12) name of xbtinfo file -'xbtinfo.p09 '
c              cruise(1:7) cruise we are looking at -'p090508'
c	OUTPUT:
c	        iport(9) - 0 or 1 - 1 if true - different for each cruise!
c	                 - this is port of calls
c              
        character xbtinfo*12, cruise*7, prev*5, next*5
        character xbtinfo1*22, test*5, track*5, shipname*3
        character cruise8*8
        dimension iport(9),linename(7)
        data xbtinfo1/'/data/xbt/xbtinfo.p08 '/

        write(xbtinfo1(11:22),'(a12)') xbtinfo(1:12)

        open(22,file=xbtinfo1,status='old',form='formatted',err=600)
c skip 3:
        read(22,*,err=600)
        read(22,*,err=600)
        read(22,*,err=600)
        icount = 1
        print *, 'cruise(4:7)=',cruise(4:7)

        do 100 i = 1, 300
c test is cruise name (0505), track is the ascii chars to define track it took
         read(22,500,end=200,err=222) test(1:5), track(1:5)
500      format(a5,19x,a5)
c skip ---- lines
         if(test(1:5).eq.'-----') go to 100
c we have a match:
c this does not work for ix28 - need to compare test(1:5) to cruise(4:8)
         if(cruise(1:3).eq.'p28') then
          if(test(1:5).eq.cruise8(4:8)) then
            print *, 'match track=',track(1:5)
            call rdtrack(xbtinfo,track,iport,linename)
            if(icount.eq.1) prev(1:5) = test(1:5)
50          read(22,'(a5)',end=200,err=222) next(1:5)
            if(next(1:5).eq.'-----') go to 50
c this is duplicate, what to do?
c this goto 50 screws up ix28:
c            if(next(1:4).eq.cruise(4:7)) go to 50
            if(next(1:4).eq.'    ') next(1:5) = test(1:5)
            go to 101
          endif
         else

         if(test(1:4).eq.cruise(4:7)) then
            print *, 'match track=',track(1:5)
            call rdtrack(xbtinfo,track,iport,linename)
            go to 101
         endif
        endif
        icount = icount + 1
100     continue
101     continue
        go to 300

200     continue
        write(*,*) 'end of ', xbtinfo1
        go to 300
222     continue
        write(*,*) 'error of ', xbtinfo1
        go to 300
600	write(*,*) 'error opening xbtinfo file:', xbtinfo

300     continue
        close(22)
        return
        end
c-------------------------------------------------------------------

        subroutine rdtrack(xbtinfo,tr,iport,linename)
        character xbtinfo*11, tr*5
        dimension iport(9),linename(7)

        do 10 i = 1, 9
10      iport(i) = 0

        do 11 i = 1, 6
11      linename(i) = 0


        if(xbtinfo(9:11).eq.'p08') then
c iport(1) = D  Dunedin 
           if(tr(1:1).eq.'D'.or.tr(5:5).eq.'D') iport(1) = 1
c iport(2) = P  Panama  
           if(tr(1:1).eq.'P'.or.tr(5:5).eq.'P') iport(2) = 1
c iport(3) = A  Auckland
           if(tr(1:1).eq.'A'.or.tr(5:5).eq.'A') iport(3) = 1
           linename(1) = 1

        elseif(xbtinfo(9:11).eq.'p09') then
c first get port names:
c iport(1) = A  Auckland
           if(tr(1:1).eq.'A'.or.tr(2:2).eq.'A'.or.
     $        tr(3:3).eq.'A'.or.tr(4:4).eq.'A') iport(1) = 1
c iport(2) = E  East Cape
           if(tr(1:1).eq.'E'.or.tr(2:2).eq.'E'.or.
     $        tr(3:3).eq.'E'.or.tr(4:4).eq.'E') iport(2) = 1
c iport(3) = H  Honolulu
           if(tr(1:1).eq.'H'.or.tr(2:2).eq.'H'.or.
     $        tr(3:3).eq.'H'.or.tr(4:4).eq.'H') iport(3) = 1
c iport(4) = S  Suva
           if(tr(1:1).eq.'S'.or.tr(2:2).eq.'S'.or.
     $        tr(3:3).eq.'S'.or.tr(4:4).eq.'S') iport(4) = 1
c iport(5) = W  Seattle
           if(tr(1:1).eq.'W'.or.tr(2:2).eq.'W'.or.
     $        tr(3:3).eq.'W'.or.tr(4:4).eq.'W') iport(5) = 1
c iport(6) = F  San Francisco  (was Sf)
           if(tr(1:1).eq.'F'.or.tr(2:2).eq.'F'.or.
     $        tr(3:3).eq.'F'.or.tr(4:4).eq.'F') iport(6) = 1
c iport(7) = L  Los Angeles
           if(tr(1:1).eq.'L'.or.tr(2:2).eq.'L'.or.
     $        tr(3:3).eq.'L'.or.tr(4:4).eq.'L') iport(7) = 1
c iport(8) = T  Tahiti
           if(tr(1:1).eq.'T'.or.tr(2:2).eq.'T'.or.
     $        tr(3:3).eq.'T'.or.tr(4:4).eq.'T') iport(8) = 1
c iport(9) = U  Tauranga (was Tr)
           if(tr(1:1).eq.'U'.or.tr(2:2).eq.'U'.or.
     $        tr(3:3).eq.'U'.or.tr(4:4).eq.'U') iport(9) = 1

c NEXT figure out line names (PX06, etc)
c PX06:
           if((iport(1).eq.1.or.iport(2).eq.1.or.iport(9).eq.1).and.
     $         iport(4).eq.1) linename(1) = 1

c PX09     
           if((iport(1).eq.1.or.iport(4).eq.1).and.
     $         iport(3).eq.1) linename(2) = 1
c test this if we go to Seattle at all then PX09/PX39 is true (I think):
           if(iport(5).eq.1) then
               linename(2) = 1
               linename(3) = 1
           endif

c PX39     
           if((iport(3).eq.1.).and.
     $         iport(5).eq.1) linename(3) = 1
c PX31     
           if((iport(4).eq.1.).and.
     $        (iport(6).eq.1.or.iport(7).eq.1)) linename(4) = 1
c PX12     
           if((iport(4).eq.1.).and.
     $         iport(8).eq.1) linename(5) = 1
c PX13     
           if((iport(4).eq.0.).and.
     $        (iport(1).eq.1.or.iport(9).eq.1).and.
     $        (iport(6).eq.1.or.iport(7).eq.1)) linename(7) = 1
c PX18     
           if((iport(8).eq.1.).and.
     $         iport(7).eq.1) linename(6) = 1
c kludge fix (if have PX12, cannot have PX31...
           if(linename(5).eq.1.) linename(4) = 0

        elseif(xbtinfo(9:11).eq.'p28') then
           if(tr(1:1).eq.'H'.or.tr(5:5).eq.'H') iport(1) = 1
           if(tr(1:1).eq.'D'.or.tr(5:5).eq.'D') iport(2) = 1
           linename(1) = 1

c IX15/21
        elseif(xbtinfo(9:11).eq.'p15') then

c iport(1) = C - Cap Ste. Marie, Madagascar
           if(tr(1:1).eq.'C'.or.tr(2:2).eq.'C'.or.
     $        tr(3:3).eq.'C'.or.tr(4:4).eq.'C'.or.
     $        tr(5:5).eq.'C') iport(1) = 1
c iport(2) = D - Durban, South Africa
           if(tr(1:1).eq.'D'.or.tr(2:2).eq.'D'.or.
     $        tr(3:3).eq.'D'.or.tr(4:4).eq.'D'.or.
     $        tr(5:5).eq.'D') iport(2) = 1
c iport(3) = F - Fremantle, Australia
           if(tr(1:1).eq.'F'.or.tr(2:2).eq.'F'.or.
     $        tr(3:3).eq.'F'.or.tr(4:4).eq.'F'.or.
     $        tr(5:5).eq.'F') iport(3) = 1
c iport(4) = M - Mauritius
           if(tr(1:1).eq.'M'.or.tr(2:2).eq.'M'.or.
     $        tr(3:3).eq.'M'.or.tr(4:4).eq.'M'.or.
     $        tr(5:5).eq.'M') iport(4) = 1
c iport(5) = R - Reunion
           if(tr(1:1).eq.'R'.or.tr(2:2).eq.'R'.or.
     $        tr(3:3).eq.'R'.or.tr(4:4).eq.'R'.or.
     $        tr(5:5).eq.'R') iport(5) = 1
c iport(6) = S - Sydney
           if(tr(1:1).eq.'S'.or.tr(2:2).eq.'S'.or.
     $        tr(3:3).eq.'S'.or.tr(4:4).eq.'S'.or.
     $        tr(5:5).eq.'S') iport(6) = 1
c iport(7) = E - Melbourne
           if(tr(1:1).eq.'E'.or.tr(2:2).eq.'E'.or.
     $        tr(3:3).eq.'E'.or.tr(4:4).eq.'E'.or.
     $        tr(5:5).eq.'E') iport(7) = 1

c NEXT figure out line names (PX44, etc)
c IX21
           if((iport(1).eq.1.or.iport(2).eq.1.or.
     $         iport(5).eq.1).and.
     $         iport(4).eq.1) linename(1) = 1
c IX15:
           if((iport(3).eq.1.or.iport(6).eq.1.or.iport(7).eq.1).and.
     $         iport(4).eq.1) linename(2) = 1
c IX02:
           if(iport(2).eq.1.and.iport(3).eq.1) linename(3) = 1
c IX31:
           if(iport(6).eq.1.or.iport(7).eq.1) linename(4) = 1

c PX30/31
        elseif(xbtinfo(9:11).eq.'p31') then
c iport(1) = B Brisbane
           if(tr(1:1).eq.'B'.or.tr(2:2).eq.'B'.or.
     $        tr(4:4).eq.'B') iport(1) = 1
c iport(2) = L Lautoka
           if(tr(1:1).eq.'L'.or.tr(2:2).eq.'L'.or.
     $        tr(4:4).eq.'L') iport(2) = 1
c iport(3) = S Suva   
           if(tr(1:1).eq.'S'.or.tr(2:2).eq.'S'.or.
     $        tr(4:4).eq.'S') iport(3) = 1
c iport(4) = N Noumea 
           if(tr(1:1).eq.'N'.or.tr(2:2).eq.'N'.or.
     $        tr(4:4).eq.'N') iport(4) = 1
           linename(1) = 1

c PX34
        elseif(xbtinfo(9:11).eq.'p34') then
c iport(1) = W Wellington
           if(tr(1:1).eq.'W'.or.tr(4:4).eq.'W') iport(1) = 1
c iport(2) = NP New Plymouth
           if(tr(1:2).eq.'NP') iport(2) = 1
c iport(3) = S Sydney    
           if(tr(1:1).eq.'S'.or.tr(4:4).eq.'S') iport(3) = 1
           linename(1) = 1

c PX44/PX10/PX37:
        elseif(xbtinfo(9:11).eq.'p37') then
c iport(1) = S  San Francisco
           if(tr(1:1).eq.'S'.or.tr(2:2).eq.'S'.or.
     $        tr(3:3).eq.'S'.or.tr(4:4).eq.'S') iport(1) = 1
c iport(2) = H  Honolulu, Hawaii
           if(tr(1:1).eq.'H'.or.tr(2:2).eq.'H'.or.
     $        tr(3:3).eq.'H'.or.tr(4:4).eq.'H') iport(2) = 1
c iport(3) = G Guam
           if(tr(1:1).eq.'G'.or.tr(2:2).eq.'G'.or.
     $        tr(3:3).eq.'G'.or.tr(4:4).eq.'G') iport(3) = 1
c iport(4) = T Taiwan
           if(tr(1:1).eq.'T'.or.tr(2:2).eq.'T'.or.
     $        tr(3:3).eq.'T'.or.tr(4:4).eq.'T') iport(4) = 1
c iport(5) = K Hong Kong
           if(tr(1:1).eq.'K'.or.tr(2:2).eq.'K'.or.
     $        tr(3:3).eq.'K'.or.tr(4:4).eq.'K') iport(5) = 1
c NEXT figure out line names (PX44, etc)
c PX44
           if((iport(4).eq.1.or.iport(5).eq.1).and.
     $         iport(3).eq.1) linename(1) = 1
c PX10:
           if(iport(3).eq.1.and.iport(2).eq.1) linename(2) = 1
c PX37:
           if(iport(1).eq.1.and.iport(2).eq.1) linename(3) = 1

        elseif(xbtinfo(9:11).eq.'p38') then
c iport(1) = H  Hawaii         
           if(tr(1:1).eq.'H'.or.tr(2:2).eq.'H'.or.
     $        tr(3:3).eq.'H'.or.tr(4:4).eq.'H') iport(1) = 1
c iport(2) = V  Valdez         
           if(tr(1:1).eq.'V'.or.tr(2:2).eq.'V'.or.
     $        tr(3:3).eq.'V'.or.tr(4:4).eq.'V') iport(2) = 1
c iport(3) = N  Nikiski (call is Kodiak - need to check with Dave)
           if(tr(1:1).eq.'N'.or.tr(2:2).eq.'N'.or.
     $        tr(3:3).eq.'N'.or.tr(4:4).eq.'N') iport(3) = 1
c iport(4) = M  Homer 
           if(tr(1:1).eq.'M'.or.tr(2:2).eq.'M'.or.
     $        tr(3:3).eq.'M'.or.tr(4:4).eq.'M') iport(4) = 1
c iport(5) = O  Oahu  
           if(tr(1:1).eq.'O'.or.tr(2:2).eq.'O'.or.
     $        tr(3:3).eq.'O'.or.tr(4:4).eq.'O') iport(4) = 1
           linename(1) = 1

        elseif(xbtinfo(9:11).eq.'p22') then
           if(tr(1:2).eq.'HI'.or.tr(4:5).eq.'HI') iport(1) = 1
           if(tr(1:2).eq.'KG'.or.tr(4:5).eq.'KG') iport(2) = 1
           if(tr(1:2).eq.'PA'.or.tr(4:5).eq.'PA') iport(3) = 1
           if(tr(1:2).eq.'PS'.or.tr(4:5).eq.'PS') iport(4) = 1
           if(tr(1:2).eq.'SI'.or.tr(4:5).eq.'SI') iport(5) = 1
           linename(1) = 1

        elseif(xbtinfo(9:11).eq.'p81') then
           if(tr(1:2).eq.'H '.or.tr(4:5).eq.'H ') iport(1) = 1
           if(tr(1:2).eq.'Hw'.or.tr(4:5).eq.'Hw') iport(2) = 1
           if(tr(1:2).eq.'Ha'.or.tr(4:5).eq.'Ha') iport(3) = 1
           if(tr(1:2).eq.'Hi'.or.tr(4:5).eq.'Hi') iport(4) = 1
           if(tr(1:2).eq.'C '.or.tr(4:5).eq.'C ') iport(5) = 1
           if(tr(1:2).eq.'PM'.or.tr(4:5).eq.'PM') iport(6) = 1
c PX81:
           if(iport(1).eq.1.and.(iport(5).eq.1.or.
     $          iport(6).eq.1)) linename(1) = 1
c PX25:
           if((iport(2).eq.1.or.iport(3).eq.1.or.iport(4).eq.1).and.
     $         (iport(5).eq.1.or.iport(6).eq.1)) linename(2) = 1

        else
           write(*,*) 'ALERT ALERT *****************!'
           write(*,*) 'rewrite rdtrack for this line!'
        endif
        write(*,*)'in rdxbtinfo1 iport=',iport
        write(*,*)'in rdxbtinfo1 linename=',linename

        return
	end
