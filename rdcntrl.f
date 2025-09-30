	subroutine rdcntrl(ierror,len_acruise,acruise,xmaxspd,launcher,
     $             deadmin,dropmin,relodmin,tdzmx,tdzrms,dtdzmn,dtdzth,
     $             dtmx,dtmx700,tm_pl_mn,tm_pl_mx,acontrol,ifile,
     $             ichkprofdepth)
c INPUT:
c	acontrol - character string of path of control.dat
c	ifile - file number for error output.   I used to always use "33"
c		but I should pass it in
c This should be able to switch between old and new control.dat formats!!!
c read Janet Brockett new format of control.dat
!16jun2015	parameter (nlines=17)
        parameter (nlines=18)
        parameter (nlnchrs=12)
        parameter (nerr=50)

        integer*4 ierror(nerr), ifile, ichkprofdepth
        integer*4 la(nlines)
        integer*4 len_acruise, launcher(nlnchrs)

	real*4 xmaxspd, deadmin, dropmin, relodmin
	real*4 tdzmx,tdzrms,dtdzmn,dtdzth,dtmx,dtmx700
	real*4 tm_pl_mn,tm_pl_mx
	character*(*) acruise
	character*(*) acontrol

        character a(nlines)*34
        character a72*72, acut*72

        data  a(1)/'Ship Name ='/
        data  a(2)/'Cruise Name ='/
        data  a(3)/'Operator Name ='/
        data  a(4)/'Max Ship Speed ='/
        data  a(5)/'Auto Launcher Sequence ='/
        data  a(6)/'Max Plot  Temp ='/
        data  a(7)/'Min Plot Temp ='/
! 14jul2014 Janet used "Reakon", Ibis correctly wants "Reckon": (23:23)
        data  a(8)/'Max Minutes to Dead Reakon ='/
        data  a(9)/'Max min duration between drops ='/
        data a(10)/'Empty Launcher Reload Alarm Time ='/
        data a(11)/'Max Displacement ='/
        data a(12)/'Max Rms Displacement ='/
        data a(13)/'Min dtdz ='/
        data a(14)/'Min dtdz Displacement Test ='/
        data a(15)/'Max Delta ='/
        data a(16)/'Max 700m Delta ='/
        data a(17)/'Check Profile Depth ='/
! 01jul2014 add this for Ibis changing format:
        data a(18)/'Min Plot  Temp ='/
!
c may want to check these default values.   Only used if error reading.
	xmaxspd1 = 30.
        deadmin1 = 60.
	dropmin1 = -90.
	relodmin1 = 15.
        tdzmx1 = 450.
	tdzrms1 = 110.
        dtdzmn1 = -0.01100
	dtdzth1 = 0.00050
	dtmx1 = 4.6
        dtmx7001 = 0.8
	tm_pl_mn1 = 0.0
	tm_pl_mx1 = 30.0
	ichkprofdepth1 = 700

c set lengths of "a" array:
        do 10 i = 1, nlines
c getslen won't work because string do not end with a ' ' !!
c??	   call getslen(a(i),la(i))
           la(i) = len_trim(a(i))
10	continue

	write(ifile,*)'rdcntrl, acontrol=',acontrol,'nlines=',nlines
	open(22,file=acontrol,status='old',form='formatted',
     $         err=500)

c check 1st line of file to see what version it is:
	read(22,'(a)',err=301) a72
	rewind(22) 

c new format:

	if(a72(1:la(1)).eq.a(1)(1:la(1))) then

	do 200 i = 1, nlines
	   read(22,'(a)',err=301,end=301) a72
           write(ifile,*) 'a72=',a72
	   do 150 j = 1, nlines
              ifound = 0
!             special case for Reakon vs Reckon:
              if(j.eq.8) then
                 if(a72(1:19).eq.a(8)(1:19)) then
                    lacut = 72 - la(j) + 1
                    laj1 = la(j) + 1
                    acut(1:lacut) = a72(laj1:72)
                    ifound = 1
                 endif
              else
	       if(a72(1:la(j)).eq.a(j)(1:la(j))) then
		 lacut = 72 - la(j) + 1
	         laj1 = la(j) + 1
	         acut(1:lacut) = a72(laj1:72)
                 ifound = 1
               endif
              endif
              if(ifound.eq.1) then
	
	         if(j.eq.1) then
c skip ship name
	         elseif(j.eq.2) then
c cruise name
c find 1st blank space:
	            iblank = lacut
	            do 15 k = 1, lacut
		       if(acut(k:k).eq.' ') then
	                 iblank = k
	                 go to 16
	               endif
15		    continue
16	            continue
	            len_acruise = iblank - 1
	            if(len_acruise.gt.7) len_acruise = 7
	            acruise(1:len_acruise) = acut(1:len_acruise)
                    write(ifile,*)'acruise=',acruise,len_acruise
	            
	         elseif(j.eq.3) then
c operator name
c I only use this for ierrlev logging-
		    if(acut(1:5).eq.'debug') then
                      ierror(33) = 6
		    elseif(acut(1:5).eq.'debu1') then
                      ierror(33) = 7
	            endif

	         elseif(j.eq.4) then
c max ship speed = xmaxspd
	            read(acut,*,err=20) xmaxspd
	            goto 150
20	            xmaxspd = xmaxspd1

	         elseif(j.eq.5) then
c launcher sequence
	            read(acut,*,err=22) (launcher(ii),ii=1, nlnchrs)
	            goto 150
22		    continue
c if error reading launchers, set all to negative?
	            do 24 ii = 1, nlnchrs
	               launcher(i) = -1*i
24		    continue
	         elseif(j.eq.6) then
c plot temperature max
	            read(acut,*,err=25) tm_pl_mx
	            goto 150
25	            tm_pl_mx = tm_pl_mx1
	         elseif(j.eq.7) then
c plot temperature min
	            read(acut,*,err=26) tm_pl_mn
	            goto 150
26	            tm_pl_mn = tm_pl_mn1
	         elseif(j.eq.8) then
c max min to deadreckon = deadmin
	            read(acut,*,err=28) deadmin
	            goto 150
28	            deadmin = deadmin1

	         elseif(j.eq.9) then
c max min to between drops = dropmin
	            read(acut,*,err=30) dropmin
	            write(ifile,*)'acut',acut
	            write(ifile,*)'dropmin=',dropmin
	            goto 150
30		    dropmin = dropmin1

	         elseif(j.eq.10) then
c empty launcher reload time = relodmin
	            read(acut,*,err=32) relodmin
	            goto 150
32		    relodmin = relodmin1
	         elseif(j.eq.11) then
c tdzmx
	            read(acut,*,err=34) tdzmx
	            goto 150
34		    tdzmx = tdzmx1
	         elseif(j.eq.12) then
c tdzrms
	            read(acut,*,err=36) tdzrms
	            goto 150
36		    tdzrms = tdzrms1
	         elseif(j.eq.13) then
c dtdzmn
	            read(acut,*,err=38) dtdzmn
	            goto 150
38		    dtdzmn = dtdzmn1
	         elseif(j.eq.14) then
c dtdzth
	            read(acut,*,err=40) dtdzth
	            goto 150
40		    dtdzth = dtdzth1

	         elseif(j.eq.15) then
c dtmx
	            read(acut,*,err=42) dtmx
	            goto 150
42		    dtmx = dtmx1
	         elseif(j.eq.16) then
c dtmx700
	            read(acut,*,err=44) dtmx700
	            goto 150
44		    dtmx700 = dtmx7001
	         elseif(j.eq.17) then
c ichkprofdepth
	            read(acut,*,err=45) ichkprofdepth
	            goto 150
45		    ichkprofdepth = ichkprofdepth1
         elseif(j.eq.18) then
! plot temperature min
            read(acut,*,err=46) tm_pl_mn
            if(iw.eq.1) write(ifile,*)'tm_pl_mn=',tm_pl_mn
            goto 150
46          tm_pl_mn = tm_pl_mn1
	         endif
	      endif

150	continue
	
200	continue
         if(tm_pl_mn.eq.tm_pl_mx) then
            tm_pl_mn = tm_pl_mn1
            tm_pl_mx = tm_pl_mx1
         endif

	go to 900


c old format:
	else

	read(22,'(a)',err=301) acruise
	len_acruise=len_trim(acruise)
c board addresses
	read(22,*,err=301)
c drop time in seconds, 0, screen type
	read(22,*,err=301)
	read(22,551,err=301) deadmin, dropmin, relodmin, runsec
551	format(4f5.0)
	read(22,520,err=301)tdzmx,tdzrms,dtdzmn,dtdzth,dtmx,dtmx700
520	format(2f6.0,2f9.5,2f5.1)
c tem plot min, max
	read(22,*) ii, tm_pl_mn,tm_pl_mx
	if(tm_pl_mn.eq.0.0.and.tm_pl_mx.eq.0.0)then
	   tm_pl_mn = tm_pl_mn1
	   tm_pl_mx = tm_pl_mx1
	endif
c shipname
	read(22,*,err=301)
c operator name
	read(22,*,err=301) 
c gps type, com port
	read(22,*,err=301) 
c ship minimum speed (knots), ship maximum speed
	read(22,522,err=301) xminspeed, xmaxspd
522	format(2f5.1)
c data path
	read(22,*,err=301)
c read version from control.dat
	read(22,*,err=301)
	read(22,550,err=13,end=13) (launcher(i),i=1,6)
550	format(6i3)
	go to 146
13	continue
c set all launchers negative (empty) if error reading control.dat
	do 14 i = 1, 6
14	launcher(i) = -1*i
	ierror(14) = 1
146	continue
c fill in launcher(7 to nlnchrs)
	do 47 i = 7, nlnchrs
47	launcher(i) = -99

	endif

	go to 900

301	ierror(16) = 1
        write(ifile,*) 'after 301'
	go to 900
500	ierror(15) = 1
	go to 900

900	continue
	close(22)

	return
	end	
	
