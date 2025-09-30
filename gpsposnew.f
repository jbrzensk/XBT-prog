         program gpsposnew
! compile with: make -f gpsposnew.mk

! 31jan2023 fudge fixes to not worry about navigate or callsign of TP's
!12jun2015 - set serial = -000001 for now since srp formats differ...
! 13sep2013 LL-if new 'q' file exists, add header info to it also (sn,dom, seasid)
! 12dec2012LL- carry original interp'd temp thru (after class 5) rewrite of e.
! 3apr2012 LL - add a check for Sippican SN -> DoM RUN BEGIN to my <cruise>serial.txt
! 31jan2012 LL check callsign from SRP on first drop, ask user
!   if it's ok, then if all other e's have same callsign, peachy,
!   if not, alert user (use /data/xbt/callsign.txt !)
! ~28jan2012 LL Added read from serial.txt to get xbt DoM...(1feb2012 + case, but not in e...)
! 2011?? Added read from serial.txt to get xbt serial number
! 24may2010 - read matching SRP file to get callsign, SEASID and Serial 
! number! change 2nd line of e file from chr21 to chr49
! search "lisa fudge" for iclass headache
! 5nov2009 LL - mods for iclass and add XBT & recorder type to header of e.
! 13sep2005 - add rdcntrl
! 22feb2001 LL - gts transmission col added
! Jan 2000 - JG made y2k fixes.
! 10-23-97 t5's - renavigate t5's too!  So deal with t5 dir. LL
! 9-5-96 Reads new nav file format!!!!
!
! hacked version for sun - goes through stations.dat line by line 
! and renavigates ALL drops, rewrites position in e file and creates
! p099105.dat (using correct cruise and date)
!#  GPSPOS.FOR   version 3.1
!# find an un-navigated xbt drop by looking at stations.dat
!# navigate using interpolation or extrapolation
!# write station position to stations.dat, data file and edited file
!# read cruise designator from control.dat
!# altered to look for previous day nav file if present day non-existing
!
        parameter (nlnchrs=12)
        parameter (nerr=50)
        parameter (nqmax=1600)
        implicit real*8 (a-h,o-z)
        character f1*12, chr56*56, fnav*10, chr38*38, clat*2, clats*2
! fq is new q file: s371308q.001 (full resolution)
        character fq*12
        character*24 qchr24(nqmax)
        character ch4*4, chr49*49, f2*11, clon*2, srp*16
        character callsign*7, seasid*8, serial*18
        character callsign1*7, callsigntxt*7
        character*24 shipname, ians*1
        character*20  chr20(1000), ft5*15, trans*1
        character  adate*21, adrop*3
        integer*4 ierror(nerr), ifile, ichkprofdepth
        integer*4 len_acruise, launcher(nlnchrs)
        real*4 xmaxspd, deadmin, dropmin, relodmin
        real*4 tdzmx,tdzrms,dtdzmn,dtdzth,dtmx,dtmx700
        real*4 tm_pl_mn,tm_pl_mx
        character*7 acruise
        character*11 acontrol
        character*3 dnum(1000)
        character*7 serialnum(1000), srpserial, srpdom*10
        character*18 serialdom(1000)
! sipp_dor_case is sippican date of manu run begin plus case
        character*15 sipp_dor_case(1000)
        character*4 case(1000)
        character*17 fserial
         data f1/'p099105s.000'/, f2/'p099105.dat'/
         data fq/'p099105q.000'/
         data ft5/'t5/p099105e.000'/, acontrol/'control.dat'/
         data srp/'p099105r_000.SRP'/
         data callsign/'       '/
         data seasid/'        '/
         data serial/'                  '/
        data fserial/'p371110serial.txt'/
! blank out serial num info if error reading it in:
        do i = 1, 1000
           dnum(i) = '   '
           serialnum(i) = '       '
           serialdom(i) = '                  '
           sipp_dor_case(i) = '               '
           case(i) = '    '
        enddo
        ifixit = 0
        
! prompt for xbt/recorder type:
        write(*,*)'What type probe is this e file? (enter number):'
        write(*,*)'>1 - Sippican Deep Blue, old coefficients (code 051)'
        write(*,*)' 2 - Sippican Deep Blue, new coefficients (code 052)'
        write(*,*)' 3 - Sippican T-7, old coefficients       (code 041)'
        write(*,*)' 4 - Sippican T-7, new coefficients       (code 042)'
        write(*,*)' 5 - Sippican T-4, old coefficients       (code 001)'
        write(*,*)' 6 - Sippican T-4, new coefficients       (code 002)'
        write(*,*)' 7 - Spartan XBT-5DB                      (code 441)'
        write(*,*)' 0 - Other - stop and add to gpsposnew.f!'
        read(5,*) iprobe
        write(*,*) '-----------------------------------------------'
        write(*,*)'What type recorder did you use? (enter number):'
        write(*,*)' 1 - Sippican MK-12                       (code 05)'
        write(*,*)' 2 - Scripps Metrabyte controller         (code 31)'
        write(*,*)' 3 - Sippican MK-9                        (code 03)'
        write(*,*)'>4 - Sippican MK-21                       (code 06)'
        write(*,*)' 5 - CSIRO Devil-2 XBT acquisition system (code 71)'
        write(*,*)' 0 - Other - stop and add to gpsposnew.f!'
        read(5,*) icontrol

        ipick = 0
! this readserial is pulling data from that stupid "serial.txt" file you
! create from the cruise report....
        CALL readserial(dnum,serialnum,serialdom,ipick,case,
     $                  sipp_dor_case)

!------------------------------
! rdcntrl INPUT:
!       acontrol - character string of path of control.dat
!       ifile - file number for error output.   I used to always use "33"
!               but I should pass it in
!------------------------------
! get cruise designator and find first un-navigated drop
         open(20,file='renav.dat',status='unknown',form='formatted')
         open(10,file='gpspos.out')

         ifile=10
! This should be able to switch between old and new control.dat formats!!!
! read Janet Brockett new format of control.dat
         write(ifile,*)'calling rdcntrl'
         call rdcntrl(ierror,len_acruise,acruise,xmaxspd,launcher,
     $         deadmin,dropmin,relodmin,tdzmx,tdzrms,dtdzmn,dtdzth,
     $         dtmx,dtmx700,tm_pl_mn,tm_pl_mx,acontrol,ifile,
     $             ichkprofdepth)
         write(ifile,*) 'acruise=',acruise(1:7)
         if(acruise(1:1).eq.'P') acruise(1:1) = 'p'
         f1(1:7) = acruise(1:7)
         fq(1:7) = acruise(1:7)
        srp(1:7) = acruise(1:7)
        fserial(1:7) = acruise(1:7)
! 24jan2012 LL Add output of serial numbers, DOM, etc to incorporate in a
! sio master list:
        open(37,file=fserial,status='unknown',form='formatted')

         open(7,file='stations.dat',status='old',err=130)
         f2(1:7) = f1(1:7)
         open(17,file=f2,status='unknown',err=131)
! need an index to identify the first non TP: (itpnot, ha)
         itpnot = 1
         itpnotset = 0
!
! main loop
         do 10 ia=1,1000
! testing:         do 10 ia=1,2
         read(7,'(a4)')ch4
         if(ch4.eq.'ENDD')go to 101
         backspace 7
         read(7,'(1x,a3,a56,i2,i6,1x,a1)',end=101,err=133)f1(10:12),
     $             chr56,iedt,inav, trans
!31jan2023 no need to do anything with TP's.... so
! but! if it's drop 1 then you did not read to get callsign to set the
! rest of the cruise....
         if(iedt.eq.-4) then
           itpnot = itpnot + 1
! duh, write tp info to the output version of stations.dat
! <cruisename>.dat:
        write(17,'(1x,a3,a56,i2,i6,1x,a1)',err=103)f1(10:12),chr56,iedt,
     $          inav, trans
           go to 10  ! skip TP...
         else
           isetnottp = 1  ! this telling me we've found a non-tp drop
         endif

!         write(*,*)'drop ', f1(10:12)
        srp(10:12) = f1(10:12)
        fq(10:12) = f1(10:12)
! 
! translate date and time to years after start of 1987
         read(chr56,'(4x,i2,8x,6(i2,1x))',err=133)
     $               itube,iday,imo,iyr,ihr,imin,isec
        write(*,*)'read in iyr=',iyr
! y2k correction
         if(iyr.lt.80)iyr=iyr+100
         write(*,*)iday,imo,iyr,ihr,imin,isec
!         pause
         call yrdy(iyr,imo,iday,ihr,imin,isec,yrdrop)
         write(ifile,*)'from stn.dat',iday,imo,iyr,ihr,imin,isec,yrdrop
         write(*,*)'from stn.dat',iday,imo,iyr,ihr,imin,isec,yrdrop
! what's the lat and lon before renavigating?
         read(chr56,'(31x,2f9.3)',err=133) blat, blon
! now open appropriate .nav file(s)
! find a fix before and after the drop for interpolation
! if no fix after, find fix before and extrapolate using spd and dir
!CC not in .for
         rewind(8)
         call navopen(iday,imo,iyr,ierr)
         if(ierr.eq.1)then

!         write(*,*)'ierr'
! use nav file from previous day and extrapolate using spd and dir
        iday=iday-1
                if(iday.eq.0)then
                imo=imo-1
                        if(imo.eq.0)then
                        iyr=iyr-1
                         imo=12
                        endif
                iday=31
                if(imo.eq.4.or.imo.eq.6.or.imo.eq.9.or.imo.eq.11)iday=30
                if(imo.eq.2.and.mod(iyr,4).ne.0)iday=28
                if(imo.eq.2.and.mod(iyr,4).eq.0)iday=29
                endif
CCC not in .for
         close(8)
        call navopen(iday,imo,iyr,ierr)
!31jan2023 try to continue...        if(ierr.eq.1)stop 1
        if(ierr.eq.1) goto 111
!
        do 125 j=1,10000
! try using old if error with new
! old:
502     format(6(i2,1x),6x,i4,f8.4,a2,i4,f8.4,a2,8x,f6.2,f6.1,i3)
c new (501) system nav file format!
501     format(6(i2,1x),i3,f8.4,a2,i4,f8.4,a2,4x,f6.2,f6.1,i3)
         read(8,501,end=126,err=566)kday,kmo,kyr,khr,kmin,ksec,klat,
     $                       zltm,clats,klon,zlnm,clon,spd,dir,nfix
!        write(10,*) 'AA ', kday,kmo,kyr,khr,kmin,ksec,klat
        call flush(10)
        go to 567
566     backspace(8)
        read(8,502,end=126,err=135)kday,kmo,kyr,khr,kmin,ksec,klat,
     $                       zltm,clats,klon,zlnm,clon,spd,dir,nfix
!        write(10,*) 'A ', kday,kmo,kyr,khr,kmin,ksec,klat
        call flush(10)
567     continue
         if(kyr.lt.80)kyr=kyr+100
         if(clon.eq.' W') then
            xlon=float(klon)+zlnm/60.
            xlon = 360.0 - xlon
            klon = int(xlon)
            zlnm = 60. *(xlon - real(klon))
         endif
125     continue
126     call yrdy(kyr,kmo,kday,khr,kmin,ksec,yrsav)
c         write(10,*) 'one ',kyr,kmo,kday,khr,kmin,ksec,yrsav
        go to 29
        endif
         do 20 i=1,10000
         read(8,501,end=21,err=568)jday,jmo,jyr,jhr,jmin,jsec,jlat,
     $                      xltm,clat,jlon,xlnm,clon,spd,dir,nfix
!        write(10,*) 'BB ', jday,jmo,jyr,jhr,jmin,jsec,jlat
        call flush(10)
        go to 569
568     backspace(8)
        read(8,502,end=21,err=135)jday,jmo,jyr,jhr,jmin,jsec,jlat,
     $                      xltm,clat,jlon,xlnm,clon,spd,dir,nfix
!        write(10,*) 'B ', jday,jmo,jyr,jhr,jmin,jsec,jlat
        call flush(10)
569     continue
         if(jyr.lt.80)jyr=jyr+100.
         if(clon.eq.' W') then
            xlon=float(jlon)+xlnm/60.
            xlon = 360.0 - xlon
            jlon = int(xlon)
            xlnm = 60. *(xlon - real(jlon))
         endif
         call yrdy(jyr,jmo,jday,jhr,jmin,jsec,yrnav)
c         write(10,*)'two nav',jyr,jmo,jday,jhr,jmin,jsec,yrnav
         if(i.gt.1.and.yrsav.le.yrdrop.and.yrnav.gt.yrdrop)then
         	rewind(8)
         	xlat=float(jlat)+xltm/60.
         	if(clat.eq.' S')xlat=-1.*xlat
         	xlon=float(jlon)+xlnm/60.
         	zlat=float(klat)+zltm/60.
         	if(clats.eq.' S')zlat=-1.*zlat
         	zlon=float(klon)+zlnm/60.
         call interp(yrdrop,ylat,ylon,yrsav,zlat,zlon,yrnav,xlat,xlon)
         	tnav=(yrnav-yrsav)*1440.
         	tnav=max(tnav,1.)
         	go to 102
         endif
         yrsav=yrnav
         klat=jlat
         zltm=xltm
         clats=clat
         klon=jlon
         zlnm=xlnm
c if first fix occurs after drop, need previous day
         if(i.eq.1.and.yrnav.gt.yrdrop)then
         iday=iday-1
         	if(iday.eq.0)then
         	imo=imo-1
         		if(imo.eq.0)then
         		iyr=iyr-1
                         imo=12
         		endif
         	iday=31
         	if(imo.eq.4.or.imo.eq.6.or.imo.eq.9.or.imo.eq.11)iday=30
         	if(imo.eq.2.and.mod(iyr,4).ne.0)iday=28
         	if(imo.eq.2.and.mod(iyr,4).eq.0)iday=29
         	endif
         close(8)
         call navopen(iday,imo,iyr,ierr)
!31jan2023 try to skip navigation...         if(ierr.eq.1)stop 1
         if(ierr.eq.1) go to 111
!
         do 25 j=1,10000
         read(8,501,end=26,err=666)kday,kmo,kyr,khr,kmin,ksec,klat,
     $                      zltm,clats,klon,zlnm,clon,spd,dir,nfix
!        write(10,*) 'DBB ', kday,kmo,kyr,khr,kmin,ksec,klat
        call flush(10)
        go to 667
666     backspace(8)
        read(8,502,end=26,err=135)kday,kmo,kyr,khr,kmin,ksec,klat,
     $                      zltm,clats,klon,zlnm,clon,spd,dir,nfix
!        write(10,*) 'B ', kday,kmo,kyr,khr,kmin,ksec,klat
        call flush(10)
667     continue
         if(kyr.lt.80)kyr=kyr+100
         if(clon.eq.' W') then
            xlon=float(klon)+zlnm/60.
            xlon = 360.0 - xlon
            klon = int(xlon)
            zlnm = 60. *(xlon - real(klon))
         endif
25         continue
26         call yrdy(kyr,kmo,kday,khr,kmin,ksec,yrsav)
c         write(10,*) 'three',kyr,kmo,kday,khr,kmin,ksec,yrsav
         	xlat=float(jlat)+xltm/60.
         	if(clat.eq.' S')xlat=-1.*xlat
         	xlon=float(jlon)+xlnm/60.
         	zlat=float(klat)+zltm/60.
         	if(clats.eq.' S')zlat=-1.*zlat
         	zlon=float(klon)+zlnm/60.
         call interp(yrdrop,ylat,ylon,yrsav,zlat,zlon,yrnav,xlat,xlon)
         	tnav=(yrnav-yrsav)*1440.
         	tnav=max(tnav,1.)
         	go to 102
         endif
20         continue
c if last fix occurs before drop, need next day or extrapolation
21         yrsav=yrnav
         klat=jlat
         zltm=xltm
         clats=clat
         klon=jlon
         zlnm=xlnm
         iday=iday+1
         if(iday.eq.32)go to 27
         if(iday.eq.31.and.imo.eq.4)go to 27
         if(iday.eq.31.and.imo.eq.6)go to 27
         if(iday.eq.31.and.imo.eq.9)go to 27
         if(iday.eq.31.and.imo.eq.11)go to 27
         if(iday.eq.29.and.imo.eq.2.and.mod(iyr,4).ne.0)go to 27
         if(iday.eq.30.and.imo.eq.2.and.mod(iyr,4).eq.0)go to 27
         go to 28
27         iday=1
         imo=imo+1
         if(imo.eq.13)iyr=iyr+1
         if(imo.eq.13)imo=1
28         continue
         close(8)
         call navopen(iday,imo,iyr,ierr)
         if(ierr.eq.1)go to 29
         read(8,501,err=777)jday,jmo,jyr,jhr,jmin,jsec,jlat,xltm,clat,
     $               jlon,xlnm,clon,spd,dir,nfix
!        write(10,*) 'CCC ', jday,jmo,jyr,jhr,jmin,jsec,jlat
        call flush(10)
        go to 778
777     backspace(8)
        read(8,502,err=135)jday,jmo,jyr,jhr,jmin,jsec,jlat,xltm,clat,
     $               jlon,xlnm,clon,spd,dir,nfix
        write(ifile,*) 'C ', jday,jmo,jyr,jhr,jmin,jsec,jlat
        call flush(10)
778     continue
         if(jyr.lt.80)jyr=jyr+100
         if(clon.eq.' W') then
            xlon=float(jlon)+xlnm/60.
            xlon = 360.0 - xlon
            jlon = int(xlon)
            xlnm = 60. *(xlon - real(jlon))
         endif
         call yrdy(jyr,jmo,jday,jhr,jmin,jsec,yrnav)
c         write(10,*) 'four',jyr,jmo,jday,jhr,jmin,jsec,yrnav
         xlat=float(jlat)+xltm/60.
         if(clat.eq.' S')xlat=-1.*xlat
         xlon=float(jlon)+xlnm/60.
         zlat=float(klat)+zltm/60.
         if(clats.eq.' S')zlat=-1.*zlat
         zlon=float(klon)+zlnm/60.
         call interp(yrdrop,ylat,ylon,yrsav,zlat,zlon,yrnav,xlat,xlon)
         tnav=(yrnav-yrsav)*1440.
         tnav=max(tnav,1.)
         go to 102
c need to extrapolate
29         tnav=-1.*(yrdrop-yrsav)*1440.
         tnav=min(tnav,-1.)
         tnavh=-1.*tnav/60.
         zlat=float(klat)+zltm/60.
         if(clats.eq.' S')zlat=-1.*zlat
         zlon=float(klon)+zlnm/60.
         ylat=zlat+tnavh*spd*cos(dir*3.14159/180.)/60.
         ylon=zlon+tnavh*spd*sin(dir*3.14159/180.)/
     $      (cos(ylat*3.14159/180.)*60.)
c
c         write(10,*) cos(ylat*3.14159/180.)
c         write(10,*) sin(dir*3.14159/180.)
c         write(10,*) zlon, tnavh, spd
c
c         write(*,*)' first fix: time(days) lat, lon, speed, direction '
c         write(*,'(3f15.5,2f12.2)')yrsav,zlat,zlon,spd,dir
c         write(*,*)' dr time(days), elapsed time(hrs), lat, lon '
c         write(*,'(4f15.5)')yrdrop,tnavh,ylat,ylon
         write(10,*)' first fix: time(days) lat, lon, speed, direction '
         write(10,'(3f15.5,2f12.2)')yrsav,zlat,zlon,spd,dir
         write(10,*)' dr time(days), elapsed time(hrs), lat, lon '
         write(10,'(4f15.5)')yrdrop,tnavh,ylat,ylon
102         continue  
         clat=' N'
         if(ylat.lt.0.)clat=' S'
         clats=' E'
         ylata=abs(ylat)
         ylatd=float(int(ylata))
         ylatm=(ylata-ylatd)*60.
         ylond=float(int(ylon))
         ylonm=(abs(ylon)-abs(ylond))*60.
c         write(*,'(a17,i6,2(f5.0,f6.2,a2))')' time, lat, lon: ',
c     $nint(tnav),ylatd,ylatm,clat,ylond,ylonm,clats
         write(10,'(a17,i6,2(f5.0,f6.2,a2))')' time, lat, lon: ',
     $nint(tnav),ylatd,ylatm,clat,ylond,ylonm,clats
        write(chr56(32:40),'(f9.3)')ylat
        write(chr56(41:49),'(f9.3)')ylon
!
! 31jan2023 if error opening nav file, just use the position IN
! stations.dat....
111       continue
!         write(7,'(1x,a3,a56,i2,i6)',err=103)f1(10:12),chr56,iedt,nint(tnav)
        write(17,'(1x,a3,a56,i2,i6,1x,a1)',err=103)f1(10:12),chr56,iedt,
     $          nint(tnav), trans
! Is there a difference between blat/blon and ylat/ylon?
         xlatdif = abs(blat-ylat)
         xlondif = abs(blon-ylon)
         if(xlatdif.ge.0.1.or.xlondif.ge.0.1) then
            write(20,500) f1(10:12), blat, blon, inav, ylat, ylon, 
     $                    nint(tnav),xlatdif, xlondif
500            format(a3,2f9.3,i6,2f9.3,i6,2f7.3)
         endif
! 
! e file
! no e file:
! 5jul2010 write e file for all, should contain codes
!         if(iedt.eq.-1.or.iedt.eq.-2) go to 10
! t5 need to fix e file in main dir (if exists) AND t5 dir
         f1(8:8)='e'
         fq(8:8)='q'
!         write(*,*)' open file ',f1
         write(10,*)' open file ',f1
         open(9,file=f1,status='old',err=104)
! chr38 is 1st line of e/q file
         read(9,'(a37)')chr38
! chr49 is 2nd line of e/q file
! chr49(32:38) is/will be 7 digit probe serial number
! chr49(40:49) is/will be probe DoM, say 06-17-2020
         read(9,'(a49)')chr49
         write(10,*)'chr49=',chr49

! open, read srp file to get callsign, seasid, serial number.
! note: serial number may not be entered in SRP file.   May need to
! grab from separate file?
! reset serial(1:18) between drops!:
        serial(1:18) = '                  '
        write(10,*) 'before readsrp serial=',serial
!12jun2015 set adrop before calling readsrp, amv9srp has no drop no
        adrop(1:3) = f1(10:12)
        call readsrp(srp,callsign,seasid,srpserial,adate,adrop,ierrsrp,
     $               srpdom)
        write(10,*)'after readsrp:'
        write(10,*) 'callsign=',callsign
        write(10,*) 'seasid=',seasid
        write(10,*) 'srpserial=',srpserial
           serial = '-000001           '
        write(10,*) 'set serial=',serial
        write(10,*) 'srpdom=',srpdom
        write(10,*) 'adate=',adate
        write(10,*) 'adrop=',adrop
        call flush(10)
! if ia=1 (drop 001) then put callsign into callsign1, ask operator
! if callsign is correct, if so, continue to drops 002-XXX silently unless
! callsign of 002-XXX is different than callsign1, alert operator and ask
! what to do. ha.
!if drop 001 = TP - we're not reading it, so, how to handle this loop?
        write(*,*)'AAA callsign(1:7)=', callsign(1:7)
           write(*,*) 'ia=',ia
!no        if(ia.eq.1.and.callsign(1:7).eq.'       ') then
!no         write(*,*)'Enter callsign: '
!no         read(5,'(a)') callsign(1:7)
!no        endif
!        if(ia.eq.1) then
        if(isetnotp.eq.1) then   ! this is our first no TP probe:
           callsign1(1:7) = callsign(1:7)
           write(*,*) 'ia=',ia
           write(10,*) 'ia=',ia
           open(77,file='/data/xbt/callsign.txt',status='old',
     $             form='formatted')
           do 87 jj = 1, 200
              read(77,587,end=88,err=88) shipname, callsigntxt
587           format(a24,a7)
              write(10,*) 'read callsign.txt=',shipname, callsigntxt
              if(callsigntxt(1:7).eq.'ENDDATA') go to 86
              if(callsign1(1:7).eq.callsigntxt(1:7)) then
                 write(10,*)callsign1(1:7),'=',callsigntxt(1:7)
                 write(*,*)'drop 001 callsign=', callsign1(1:7)
                 write(*,*)'shipname=',shipname
                 write(*,*)'Is that correct? y or n'
                 read(5,'(a1)') ians
                 if(ians.eq.'y') go to 88
                 stop ' check your callsigns, exiting '
              endif
87         continue
86         continue
! if we are here then callsign1 not found in callsign.txt:
              write(10,*)'drop 001 callsign=',callsign1(1:7)
              write(*,*)'drop 001 callsign=',callsign1(1:7)
              write(10,*)'callsigntxt= ',callsigntxt(1:7)
              write(*,*)'callsigntxt= ',callsigntxt(1:7)
              write(*,*)'not found, enter callsign:'
              callsign(1:7) = '       '
              callsign1(1:7) = '       '
              read(5,'(a)') callsign(1:7)
              callsign1(1:7) = callsign(1:7)
              go to 88
88         continue
           isetnottp = 1
           close(77)
! this elseif for drops (after 1st non TP) 002-XXX, only do something if not equal to prev callsign:
        elseif(isetnottp.eq.2) then
           if(callsign(1:7).ne.callsign1(1:7)) then
              if(ifixit.eq.0) then
              write(*,*)'drop 001 callsign=', callsign1(1:7)
              write(*,*)'drop ',ia,'callsign=', callsign(1:7)
              write(*,*)'What should I do to drop',ia,'callsign?: '
              write(*,*)' 1) Change the callsign to drop 001 callsign?'
              write(*,*)'    And the rest too?'
              write(*,*)' 2) Leave it as is?'
              write(*,*)' 3) Exit and you deal with it?'
              read(5,'(i1)') icallit
              if(icallit.eq.1) then
                 callsign(1:7) = callsign1(1:7)
                 ifixit = 1
              elseif(icallit.eq.2) then
! do nothing... for icallit=2
              elseif(icallit.eq.3) then
                 stop 'exiting'
              endif
              elseif(ifixit.eq.1) then
                 callsign(1:7) = callsign1(1:7)
              endif ! ifixit=0
           endif
        endif
! ierrsrp=1 means no SRP file exists
        if(ierrsrp.eq.1) then
! 4jan2011 in this case, SRP's exists for half the cruise, so callsign
! should already be set
           write(10,*)'no SRP file exists, set values'
           seasid = '-0000001'
           serial = '-000001           '
           adrop(1:3) = f1(10:12)
           adate(1:10) = chr49(1:10)
        endif
! renumber SRP's cause havoc, allow continue....
        write(10,*)'adrop(1:30)=',adrop(1:3),' f1(10:12)=',f1(10:12),
     $    ' adate(1:10)=',adate(1:10),' chr49(1:10)=',chr49(1:10)
        if(adrop(1:3).ne.f1(10:12)) then
           write(*,*) 'drop nums do not match, check date to cont'
           write(*,*) adrop(1:3), ' ', f1(10:12)
           write(10,*) 'drop nums do not match, check date to cont'
           write(10,*) adrop(1:3), ' ', f1(10:12)
           if(adate(1:10).ne.chr49(1:10)) then
              stop 'A adate ne chr49'
           endif
        endif
        if(adate(1:10).ne.chr49(1:10)) then
           write(10,*) 'Check your e file for ctrlMs'
           write(10,*) 'B adate ne chr49'
           stop 'B adate ne chr49'
        endif
        write(10,*) 'callsign=',callsign
        write(10,*) 'seasid=',seasid
        write(10,*) 'serial=',serial
        chr38(14:20) = callsign(1:7)
        chr49(23:30) = seasid(1:8)
! compare serial number from srp and serial.txt:
! if neg from srp, then not entered.  Try serial.txt
!another havoc line from renumbered srp files:  
!        read(adrop(1:3),'(i3)') idrop
        read(srp(10:12),'(i3)') idrop
!-------------
!31jan2023- maybe you SHOULD use srpserial !!!!
!7oct2015: Don't do anything with the srpserial - rider screws it up...
        if(serialnum(idrop).ne.srpserial) then
           print *, 'idrop=',idrop, 'serialnum(idrop)=',
     $              serialnum(idrop),' ne ', srpserial
!           if(srpserial.ne.'0000000') stop
        endif
!-------------
        write(10,*)idrop,serial,'serialnum=',serialnum(idrop),
     $              serialdom(idrop)
        write(10,*)'serial=',serial
        if((serial(1:1).eq.'-').or.(serial(2:6).eq.'00000')) then
           if(serialdom(idrop)(1:7).ne.'       ') then
              serial(1:18) = serialdom(idrop)(1:18)
           endif
        endif
        write(10,*)'2nd serial=',serial
! 3apr2012 LL and if we still have no DoM and/or case, use the one
! found from the serial-sippican-all.txt file:
! first one is missing DoM:
        if(serial(9:18).eq.'          ') then
           if(sipp_dor_case(idrop)(1:10).ne.'          ') then
              serial(9:18) = sipp_dor_case(idrop)(1:10)
           endif
        endif
        
! This is writing contents of serial(1:18) to chr49 for output to e/q:
! chr49(32:38) is/will be 7 digit probe serial number
! chr49(40:49) is/will be probe DoM, say 06-17-2020
! if ipick=0 use SRP SN and dom...
        if(ipick.eq.0) then
         chr49(32:38) = srpserial(1:7)
         chr49(40:49) = srpdom(1:10)
        else 
         chr49(32:49) = serial(1:18)
        endif

!24mar2005 - check if seconds in e file match seconds in stations.dat,
! if not, set = to seconds in stations.dat
         read(chr49(20:21),'(i2)') iesec
         if(iesec.ne.isec) write(chr49(20:21),'(i2)') isec
!
         do 47 ik=1, 1000
           chr20(ik) = '                    '
            read(9,'(a20)',end=48,err=48) chr20(ik)
47         continue
48         continue
         close(9)
         iend = ik - 1
         write(chr38(22:28),'(f7.3)')ylat
         write(chr38(29:29),'(a1)')' '
         write(chr38(30:36),'(f7.3)')ylon
! tube to e file, -1= hand so set =0
        if(itube.eq.-1) itube = 0
           write(chr38(38:38),'(i1)') itube

! 5nov2009 LL add xbt/recorder type to chr38:
        if(iprobe.eq.1) then
           chr38(7:9) = '051'
        elseif(iprobe.eq.2) then
           chr38(7:9) = '052'
        elseif(iprobe.eq.3) then
           chr38(7:9) = '041'
        elseif(iprobe.eq.4) then
           chr38(7:9) = '042'
        elseif(iprobe.eq.5) then
           chr38(7:9) = '001'
        elseif(iprobe.eq.6) then
           chr38(7:9) = '002'
        elseif(iprobe.eq.7) then
           chr38(7:9) = '441'
        else
           stop 'no real probe type'
        endif

c Sippican mk12 recorder
        if(icontrol.eq.1) then
           chr38(11:12) = '05'
        elseif(icontrol.eq.2) then
           chr38(11:12) = '31'
        elseif(icontrol.eq.3) then
           chr38(11:12) = '03'
        elseif(icontrol.eq.4) then
           chr38(11:12) = '06'
        elseif(icontrol.eq.5) then
           chr38(11:12) = '71'
        elseif(icontrol.eq.0) then
           stop 'no real recorder type'
        else
           stop 'no real recorder type'
        endif
! write to <acruise>serial.txt:
! 3apr2012 LL add sipp_dor_case too (ha)
!                     cruise name,  drop no   ,date of drop, serial+DOM
        write(37,579) acruise(1:7), chr38(3:5), chr49(2:11),
     $                chr49(32:49), case(idrop), sipp_dor_case(idrop)
579     format(a7,1x,a3,1x,a10,1x,a18,1x,a4,1x,a15)
! alert me if case is not equal to sipp_dor_case
        if(case(idrop)(1:4).ne.sipp_dor_case(idrop)(12:15)) then
           write(*,*)'diff case number:', idrop,' ',case(idrop),
     $             ' ',sipp_dor_case(idrop)
           write(ifile,*)'diff case number:', idrop,' ',case(idrop),
     $             ' ',sipp_dor_case(idrop)
        endif

! open and write output e file:
        open(9,file=f1,status='unknown',err=104)
        write(ifile,*)'writing e file, next 2 lines header:'
        write(ifile,*) chr38
        write(ifile,*) chr49
        write(9,'(a38)')chr38
        write(9,'(a49)')chr49
! write a20 if class 5 (original value after 5), write a14 all others:
        do 49 ik=1, iend
           write(ifile,*)'ik=',ik
           write(ifile,*)'chr20(ik)=',chr20(ik)
           if(chr20(ik)(11:11).eq.'5') then
              write(9,'(a20)') chr20(ik)(1:20)
              write(ifile,'(a20)') chr20(ik)(1:20)
           else
              write(9,'(a14)') chr20(ik)(1:14)
              write(ifile,'(a14)') chr20(ik)(1:14)
           endif
49      continue
        write(ifile,*)'close e file'
        close (9)
!13sep2013 LL if q file exists, read it, close it, open it and rewrite it...
        open(19,file=fq,status='old',err=904)
! if we are here, q file exists:
        write(ifile,*)'q file exists, read and rewrite it'
! skip first 2 header lines (duplicate of e file)
        read(19,*)
        read(19,*)
        do 900 iqk = 1, nqmax
           qchr24(iqk) = '                        '
           read(19,'(a24)',end=901,err=901) qchr24(iqk)
900     continue
901     close(19)
        iqend = iqk-1
        open(19,file=fq,status='unknown',err=904)
! write same header to q file:
        write(19,'(a38)')chr38
        write(19,'(a49)')chr49
! write a24 if class 5 (original value after 5), write a14 all others:
        do 902 iqk=1, iqend
           if(qchr24(iqk)(15:15).eq.'5') then
              write(19,'(a24)') qchr24(iqk)(1:24)
           else
              write(19,'(a18)') qchr24(iqk)(1:18)
           endif
902     continue
        close (19)
904     continue
! fixed up main dir e file fine, if iedt=2, need to fix t5 dir e file,
! else, go to next drop
         if(iedt.eq.2) then
            go to 444
         else
            go to 10
         endif
104         continue
! if error opening main dir e file and it's a t5 - fix t5/e file
         if(iedt.eq.2) then
! go fix t5/e
            go to 444
         elseif(iedt.eq.1) then
            go to 105
         endif
444         continue
! fix t5 directory e file:
         ft5(4:10) = f1(1:7)
         ft5(13:15) = f1(10:12)
!         write(*,*)' open file ',f1
         write(ifile,*)' open file ',f1
         open(9,file=ft5,status='old',err=445)
         read(9,'(a38)')chr38
         read(9,'(a49)')chr49
         do 147 ik=1, 1000
            read(9,'(a14)',end=148) chr20(ik)
147         continue
148         continue
         iend = ik - 1
         write(chr38(20:35),'(2f8.2)')ylat,ylon
         close(9)
         open(9,file=ft5,status='unknown',err=445)
         write(9,'(a38)')chr38
         write(9,'(a49)')chr49
         do 149 ik=1, iend
            write(9,'(a14)') chr20(ik)
149         continue
445         continue
         close (9)
10         continue   ! end main loop

        close(37)

103         stop
105         continue
         write(*,*)' error opening file ',f1
         write(ifile,*)' error opening file ',f1
         stop
101     write(*,*)' end of file in stations.dat, no profile to navigate'
        write(ifile,*)'eof in stations.dat,no profile to navigate'
        stop 1
110     stop 'missing control.dat file-only need 1st line (cruise name)'
130     stop 'missing stations.dat'
131     print *, 'missing ', f2
        stop
132     stop 'error reading control.dat'
133     stop 'error reading stations.dat'
135     stop ' ? error reading nav file    '
         end
!
      SUBROUTINE YRDY(KYR,KMO,KDAY,KHR,KMN,KSC,YRDAY)
         implicit real*8 (a-h,o-z)
c converts input integer year, month, day, hour, minute, second to
c yearday. uses an offset for year to minimize precision problems
C remove most of year, for precision
c
      YRDAY = (FLOAT(KYR) - 87.)*365.
      FDAY = FLOAT(KMO-1)*31. + FLOAT(KDAY) + FLOAT(KHR)/24.
     *  + (FLOAT(KMN) + FLOAT(KSC)/60. )/(60.*24.)
C ACCOUNT FOR FEB...ETC
         IF (KMO .GT. 2) THEN
C TAKE ACCOUNT OF LEAP YEAR
         IF (MOD(KYR,4) .EQ. 0) FDAY = FDAY - 2.
         IF (MOD(KYR,4) .NE. 0) FDAY = FDAY - 3.
         ENDIF
C
      IF (KMO .GT. 4) FDAY = FDAY - 1.
      IF (KMO .GT. 6) FDAY = FDAY - 1.
      IF (KMO .GT. 11) FDAY = FDAY - 1.
      IF (KMO .GT. 9) FDAY = FDAY - 1.
      YRDAY = YRDAY + FDAY
      RETURN
      END
c
         subroutine navopen(iday,imo,iyr,ierr)
         character*10 fnav
         fnav='000000.nav'
         ierr=0
c open nav file
         if(iday.gt.9)write(fnav(1:2),'(i2)')iday
         if(iday.lt.10)then
           write(fnav(2:2),'(i1)')iday
           write(fnav(1:1),'(a1)')'0'
         endif
         if(imo.gt.9)write(fnav(3:4),'(i2)')imo
         if(imo.lt.10)then
           write(fnav(4:4),'(i1)')imo
           write(fnav(3:3),'(a1)')'0'
         endif
         if(iyr.ge.100.and.iyr.lt.110)then
           write(fnav(6:6),'(i1)')iyr-100
           write(fnav(5:5),'(a1)')'0'
         elseif(iyr.ge.110)then
           write(fnav(5:6),'(i2)')iyr-100
         else
           write(fnav(5:6),'(i2)')iyr
         endif
!         write(*,*)' open navigation file ',fnav
         write(ifile,*)' open navigation file ',fnav
         open(8,file=fnav,status='old',err=101)
         return
101         fnav(8:10) = 'NAV'
         open(8,file=fnav,status='old',err=100)
         return
100         write(*,*)' error opening navigation file ',fnav
         write(ifile,*)' error opening navigation file ',fnav
         ierr=1
         return
         end
         subroutine interp(yrdrop,ylat,ylon,yrsav,zlat,zlon,yrnav,xlat,
     $xlon)
         implicit real*8 (a-h,o-z)
         frac=(yrdrop-yrsav)/(yrnav-yrsav)
         ylat=zlat+(xlat-zlat)*frac
         ylon=zlon+(xlon-zlon)*frac
!         write(*,*)' first fix, second fix, interpolated position: '
!         write(*,*)' given as time(days), lat, lon '
!         write(*,'(3f15.5)')yrsav,zlat,zlon
!         write(*,'(3f15.5)')yrnav,xlat,xlon
!         write(*,'(3f15.5)')yrdrop,ylat,ylon
         write(ifile,*)' first fix, second fix, interpolated position: '
         write(ifile,*)' given as time(days), lat, lon '
         write(ifile,'(3f15.5)')yrsav,zlat,zlon
         write(ifile,'(3f15.5)')yrnav,xlat,xlon
         write(ifile,'(3f15.5)')yrdrop,ylat,ylon
         return
         end
!------------------------------------------------
         SUBROUTINE readsrp(srp,callsign,seasid,serial,adate,adrop,
     $                     ierrsrp,dom)
         parameter (nlines=18)

        character srp*16
        character callsign*7, seasid*8, serial*7, dom*10
        character aline(nlines)*34, a100*100
        character adate*21, adrop*3

        data  aline(1)/' SEAS Version: '/
        data  aline(2)/' Ship Name: '/
        data  aline(3)/' Call Sign: '/
        data  aline(4)/' Lloyds Number:  '/
        data  aline(5)/' Date/Time(dd/mm/yyyy): '/
        data  aline(6)/' Latitude(ddd.ddd): '/
        data  aline(7)/' Longitude(ddd.ddd): '/
        data  aline(8)/' Drop No: '/
        data  aline(9)/' Probe Type: '/
        data aline(10)/' Probe Code: '/
        data aline(11)/' Acoeff: '/
        data aline(12)/' Bcoeff: '/
        data aline(13)/' Probe Serial No: '/
        data aline(14)/' Recorder Type: '/
        data aline(15)/' Recorder Code: '/
        data aline(16)/' Bottom Depth: '/
        data aline(17)/' SEAS ID: '/
!        ' Probe Manufacture Date: 02/19/2020'
        data aline(18)/' Probe Manufacture Date: '/


        ierrsrp = 0
        adate(1:21)='                     '
        write(10,*)'open ', srp
        open(22,file=srp,status='old',form='formatted',err=300)
        write(10,*)'opened ', srp
! read through Seas raw file:
       write(10,*)'reading Seas raw '
! 12jun2015 - srp/amv9 have 36 header lines... seasid on 21,
!    so change this do 100 from 1,20 TO 1,36
        do 100 i = 1, 36
           read(22,'(a)',end=300,err=300) a100
           write(10,*)'a100(1:4)=',a100(1:4),' a100(2:5)=', a100(2:5)
! Callsign:
           if(a100(1:4).eq.'Call'.or.a100(2:5).eq.'Call') then
              callsign(1:7) = a100(13:19)
! make sure no CR or other junk in callsign:
              do 33 ii = 1, 7
                 ic = ichar(callsign(ii:ii))
! 48 to 122 is numbers, alphabet and some ok chars:
                 if((ic.lt.48.or.ic.gt.122).and.(ic.ne.45)) then
                    callsign(ii:ii) = ' '
                 endif
33            continue
              write(10,*)'callsign=',callsign
           elseif(a100(1:4).eq.'Date'.or.a100(2:5).eq.'Date') then
!              1234567890123456789012345678901234567890
!SEAS fmt:   ' Date/Time(dd/mm/yyyy): 26/08/2004 15:49 GMT'
!S    fmt:   ' 29- 5-2004   3:51:12'
             adate(1:21) = ' 00-00-0000  00:00:00'
!                           123456789012345678901
! well this is stupid.   Not very robust...
             if(a100(1:1).eq.'D') then
                adate(2:3) = a100(24:25)
                adate(5:6) = a100(27:28)
                adate(8:11) = a100(30:33)
                adate(14:15) = a100(35:36)
                adate(17:18) = a100(38:39)
             elseif(a100(2:2).eq.'D') then
                adate(2:3) = a100(25:26)
                adate(5:6) = a100(28:29)
                adate(8:11) = a100(31:34)
                adate(14:15) = a100(36:37)
                adate(17:18) = a100(39:40)
             endif
           elseif(a100(1:4).eq.'Drop'.or.a100(2:5).eq.'Drop') then
! Get the drop number:
! SEAS       ' Drop No: 004'
              if(a100(1:4).eq.'Drop') then
                 read(a100(10:12),'(a3)') adrop(1:3)
              elseif(a100(2:5).eq.'Drop') then
                 read(a100(11:13),'(a3)') adrop(1:3)
              endif
! probe serial number:
           elseif(a100(1:9).eq.'Probe Ser'.
     $                       or.a100(2:10).eq.'Probe Ser') then
              serial(1:7) = a100(19:25)
! make sure no CR or other junk in serial or seasid:
              do 34 ii = 1, 7
                 ic = ichar(serial(ii:ii))
! 48 to 122 is numbers, alphabet and some ok chars:
                 if((ic.lt.48.or.ic.gt.122).and.(ic.ne.45)) then
!                    write(10,*) 'ic=',ic
                    serial(ii:ii) = ' '
                 endif
34            continue
              write(10,*)'serial=',serial
! probe dom:
           elseif(a100(1:9).eq.'Probe Man'.
     $                       or.a100(2:10).eq.'Probe Man') then
              dom(1:10) = a100(26:35)
! make sure no CR or other junk in dom
! stripping out "/" too... sigh
              do 134 ii = 1, 10
                 ic = ichar(dom(ii:ii))
! 48 to 122 is numbers, alphabet and some ok chars:
                 if((ic.lt.48.or.ic.gt.122).and.(ic.ne.45)) then
                    dom(ii:ii) = ' '
                 endif
134            continue
! ok add "-" for mm-dd-yyyy....
              dom(3:3) = '-'
              dom(6:6) = '-'
              write(10,*)'srpdom=',dom
           elseif(a100(1:4).eq.'SEAS'.or.a100(2:5).eq.'SEAS') then
              seasid(1:8) = a100(11:18)
! make sure no CR or other junk in serial or seasid:
              do 35 ii = 1, 8
                 ic = ichar(seasid(ii:ii))
! 48 to 122 is numbers, alphabet and some ok chars:
                 if((ic.lt.48.or.ic.gt.122).and.(ic.ne.45)) then
                    seasid(ii:ii) = ' '
                 endif
35            continue
           else
!              write(10,*)'srp not found'
!              call flush(10)
           endif
100     continue

        go to 301



300     continue
        ierrsrp = 1
301     continue
        return
        end
!------------------------------------------------
        SUBROUTINE readserial(dnum,serialnum,serialdom,ipick,case,
     $                        sipp_dor_case)
        character*3 dnum(1000)
        character*7 serialnum(1000), sipser
        character*18 serialdom(1000)
! sipp_dor_case is sippican date of manu run begin plus case
        character*15 sipp_dor_case(1000), sipdorcase
        character*4 case(1000)
        do 5 i = 1, 1000
           dnum(i) = '   '
           serialnum(i) = '       '
           serialdom(i) = '                  '
           sipp_dor_case(i) = '               '
5       continue

        write(*,*)'Pick your format: or quit and edit gpsposnew.f'
        write(*,*)'1=  read(7,(71x,a7)) serialnum(i) '
        write(*,*)'2=  read(7,(72x,a7)) serialnum(i) '
        write(*,*)'3=  read(7,(15x,a7)) serialnum(i) '
        write(*,*)'4=  read(7,(a7)) serialnum(i) '
        write(*,*)'5=  read(7,(65x,a7)) serialnum(i) '
        write(*,*)'6=  read(7,(4x,a18,1x,a4))serialnum+dom+case(maybe)!'
        write(*,*)'7=  read(7,(72x,a7,2x,i2,1x,i2,1x,i2)) 
     $                                 serialnum(i), dd/mm/yy '
        write(*,*)'8=  read(7,(9x,a18)) serialnum+dom '
        write(*,*)'9=  read(7,(69x,a18)) serialnum+dom '
        write(*,*)'0= USE THE SRP FILE SERIAL&DOM!'
        read(5,'(i1)') ipick
        if(ipick.eq.0) go to 130   ! exit....

        write(*,*) 'opening serial.txt'
        open(7,file='serial.txt',status='old',err=130)
!
! open serial-sippican-all.txt to get DoM BEGIN RUN date and case
        open(22,file='/data/xbt/sn/serial-sippican-all.txt',
     $          status='old',err=122)
        go to 123
122     stop ' missing /data/xbt/sn/serial-sippican-all.txt'
123     continue

        do 10 i = 1, 1000
! someday change to read into array, instead of from disk for each drop
! rewind the serial-sippican-all.txt file:
            rewind(22)
! stations.dat format:           
!           read(7,'(1x,a3,68x,a7)',err=130,end=130) dnum(i),serialnum(i) 
!regular:
!           read(7,'(1x,a3,67x,a7)',err=130,end=130) dnum(i),serialnum(i) 
! yet another:
!           read(7,'(4x,a3,50x,a7)',err=130,end=130) dnum(i),serialnum(i) 
! serialnum.txt (p091007:)
!           read(7,'(i3,1x,a7)',err=130,end=130) num,serialnum(i) 
!           read(7,'(bn,i9,a7)',err=130,end=130) num,serialnum(i) 
! and yet another format!  (notes 2 new lines here because I'm not reading num
! user 45 for tabs 72 x no go
!           read(7,'(42x,a7)',err=130,end=130) serialnum(i) 
!           read(7,'(9x,a7)',err=130,end=130) serialnum(i) 
!           read(7,'(12x,a7)',err=130,end=130) serialnum(i) 
!           read(7,'(18x,a7)',err=130,end=130) serialnum(i) 
           if(ipick.eq.1) read(7,'(71x,a7)',err=130,end=130)serialnum(i)
           if(ipick.eq.2)read(7,'(72x,a7)',err=130,end=130)serialnum(i) 
           if(ipick.eq.3)read(7,'(15x,a7)',err=130,end=130)serialnum(i) 
!           read(7,'(123x,a7)',err=130,end=130) serialnum(i) 
           if(ipick.eq.4) read(7,'(a7)',err=130,end=130) serialnum(i) 
           if(ipick.eq.5)read(7,'(65x,a7)',err=130,end=130)serialnum(i) 
           if(ipick.eq.6) then
               read(7,'(4x,a18,1x,a4)',err=130,end=130)
     $                                 serialdom(i) ,case(i)
               serialnum(i)(1:7) = serialdom(i)(1:7)
           endif
           if(ipick.eq.8)read(7,'(9x,a18)',err=130,end=130)serialdom(i) 
           if(ipick.eq.9)read(7,'(69x,a18)',err=130,end=130)serialdom(i)
!
           if(ipick.le.5) then
              serialdom(i)(1:7) = serialnum(i)(1:7)
           endif
!
           if(ipick.eq.7) then
               read(7,'(72x,a7,2x,i2,1x,i2,1x,i2)',err=130,
     $                     end=130)serialnum(i) ,idd,imm,iyy
               if(iyy.ge.1) iyy = iyy + 2000 
               serialdom(i)(1:7) = serialnum(i)(1:7)
               serialdom(i)(9:11) = '00-'
               serialdom(i)(12:14) = '00-'
               if(idd.le.9) write(serialdom(i)(10:10),'(i1)') idd
               if(idd.gt.9) write(serialdom(i)(9:10),'(i2)') idd
               if(imm.le.9) write(serialdom(i)(13:13),'(i1)') imm
               if(imm.gt.9) write(serialdom(i)(12:13),'(i2)') imm
               write(serialdom(i)(15:18),'(i4)') iyy
           endif
            
!           num = i
! blank out case=0:
           if(case(i)(1:4).eq.'   0') case(i)(1:4)='    '
           write(10,*)'reading num:',i,' ',serialdom(i)
! find serialnum in serial-sippican-all.txt
           do 300 is = 1, 100000
              read(22,522,end=301) sipser, sipdorcase
522           format(a7,1x,a15)
              if(sipser(1:7).eq.serialdom(i)(1:7)) then
                 sipp_dor_case(i) = sipdorcase                
              write(10,*) 'sipser,sipdorcase',sipser, sipdorcase
                 go to 301
              endif
300        continue
301        continue
! 21nov2012 LL if case is blank from serial.txt, then try to set it
!  from the sipp_dor_case (ha, what will this break?)
           if(case(i)(1:4).eq.'    ') then
              if(sipp_dor_case(i)(12:15).ne.'    ') then
                 case(i)(1:4) = sipp_dor_case(i)(12:15)
              endif
           endif
! what is this? :
!!  on to normal code 
           dnum(i) = '000'
           if(num.le.9) then
              write(dnum(i)(3:3),'(i1)') num
           elseif(num.ge.10.and.num.le.99) then
              write(dnum(i)(2:3),'(i2)') num
           else
              write(dnum(i)(3:3),'(i3)') num
           endif
          
10      continue        
130     continue
        return
        end
