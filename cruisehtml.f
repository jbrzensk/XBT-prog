!19feb2021 LL - rm "ftp://kakapo.ucsd.edu/pub" since you put
! a soft link under /druk/html/ to /druk/ftp/pub
        program cruisehtml
!
! recompile using:
! make -f cruisehtml.mk
!
! create individual html file for each cruise
        character top1*6, top2*6, top3*60, top4*70, top5*7, top6*52
        character top7*88, top8*30, top9*29, top10*35, top11*86
        character endtd*5, endtr*5, begintr*4
        character top13*37, top14*65, top15*37, top16*49, top17*44
        character top18a*39, top18b*29, begintrl*17, begintdl*17
        character begintdc*19
        character mid1*42, mid2*56, mid3*27, mid4_22*49, mid5*32
        character mid6*48, top12*42
        character mid7*62, mid8*57, mid9*29, mid10*35, mid11*86, mid12*42
        character outhtml*12, endtable*8, begintrc*19, mid3wid50*27
        character end1*47, end2a*58, end2b*42, end2c*26, end3a*81
        character end3b*34, end3c*38, end4*16
        character end5*37, end6*7, end7*7
        character sp*2, xbtinfo*11, cruise*7, prev*5, next*5, cruise8*8
        character middown1*41, middown2*44, begintdlc2*29
        character mid4_15*54, mid4_50*49, alinename*20, mid4_38*49
        character mid4_21*49
        character mid4_05*49
        character mid4_13*49
        character mid4s37*55
        character mid4a*27, mid4b*12, shipname*3, mid4_30*52
        character outhtml28*13, mid4_28*50, mid7_28*63, mid8_28*58
        character end2a_28*60, end3a_28*79
        dimension iport(9), linename(6)

        data outhtml/'a220506.html'/
        data outhtml28/'i280506a.html'/
        data sp/'  '/
        data xbtinfo/'xbtinfo.p22'/
        data cruise/'p089901'/
        data cruise8/'p089901a'/
        data top1/'<html>'/
        data top2/'<head>'/
        data top3/
     $'<title>Scripps High Resolution XBT/XCTD Network Site</title>'/
        data top4/'<link rel=stylesheet href="../style.css" TYPE="text/c$
     $ss" MEDIA=screen>'/
        data top5/'</head>'/
        data top6/
     $'<BODY bgcolor="FFFFFF" topmargin="0" leftmargin="0">'/
        data top7/'<TABLE width="780" border="0" cellpadding="0" cellspa$
     $cing="0" align="left" valign="top">'/
        data top8/'<TR align="left" valign="top">'/
        data top9/'<TD align="left" colspan="4">'/
        data top10/'<!--#include file="a22head.html"-->'/
        data endtd/'</TD>'/
        data endtr/'</TR>'/
        data begintr/'<tr>'/
        data top11/'<td valign="top" align="left" rowspan="2" width="3">$
     $<img src="../img/blank.gif"></td>'/
        data top12/'<td valign="top" align="left" rowspan="2">'/
        data top13/'<!--#include virtual="../nav.html"-->'/
        data top14/'<td width="7" height="570" align="left" valign="top"$
     $ rowspan="2">'/
        data top15/'<img src="../img/linedrop2.jpg"></td>'/
        data top16/'<!-- right side top of table with station map -->'/
        data top17/'<td valign="top" align="center" width="660">'/
c                   1234567890123456789012345678901234567890123456789012345
        data top18a/'<table width="660" border="0" col="2" '/
        data top18b/'valign="top" align="center">'/
        data begintrl/'<tr align="left">'/
        data mid1/'<td width=300 valign="top" align="center">'/
c                  1234567890123456789012345678901234567890123456789012345
        data mid2/
     $'<table width=300 align="center" valign="top" border="0">'/
        data mid3/'<td width="20"> &nbsp;</td>'/
        data mid3wid50/'<td width="50"> &nbsp;</td>'/
        data begintdl/'<td align="left">'/
        data begintdlc2/'<td align="left" colspan="2">'/
!                        1234567890123456789012345678901234567890123456789012345
        data mid4_22/
     $'<font size="4" color="red"> AX22 0506</font></td>'/
!                     1234567890123456789012345678901234567890123456789012345
        data mid4_15/
     $'<font size="4" color="red"> IX21/IX15 0506</font></td>'/
        data mid4_21/
     $'<font size="4" color="red"> IX21 0506</font></td>'/
        data mid4_50/
     $'<font size="4" color="red"> PX50 0506</font></td>'/
        data mid4_05/
     $'<font size="4" color="red"> PX05 0908</font></td>'/
        data mid4_13/
     $'<font size="4" color="red"> PX13 0506</font></td>'/
        data mid4_28/
     $'<font size="4" color="red"> IX28 0506a</font></td>'/
        data mid4_38/
     $'<font size="4" color="red"> PX38 0505</font></td>'/
        data mid4_30/
     $'<font size="4" color="red"> PX30/31 0505</font></td>'/
        data mid4s37/
     $'<font size="4" color="red"> PX37 South 0505</font></td>'/
!      1234567890123456789012345678901234567890123456789012345
! ok p09 gets complicated...
        data mid4a/'<font size="4" color="red">'/
        data mid4b/'</font></td>'/

        data mid5/'<td width="40"> &nbsp;</td></tr>'/
        data begintdc/'<td align="center">'/
        data mid6/'<font size="3" color="black"> &nbsp;</font></td>'/
!                  1234567890123456789012345678901234567890123456789012345678901234
!
! 19feb2021 rm ftp:
        data middown1/'<a href="../www-hrx/ax22/a220311a.10.gz">'/
!                      12345678901234567890123456789012345678901
!
!        data middown1/'<a href="ftp://kakapo.ucsd.edu/pub/www-hrx/ax22/a220311a.10.gz">'/
!                       1234567890123456789012345678901234567890123456789012345678901234
        data middown2/'<font size="3">Download 10m average data</a>'/
        data mid7/'<a href="a220503.html"><font size="3">Previous cruise$
     $</a></td>'/
        data mid7_28/'<a href="a220503a.html"><font size="3">Previous cr$
     $uise</a></td>'/
        data mid8_28/'<a href="a220508a.html"><font size=3">Next cruise<$
     $/a></td>'/
        data mid8/'<a href="a220508.html"><font size=3">Next cruise</a><$
     $/td>'/
        data endtable/'</table>'/
c                  1234567890123456789012345678901234567890123456789012345
        data end1/'<td width="350" valign="center" align="center">'/
        data end2a/
     $'<a href="img/a220506s-b.gif"><img src="img/a220506s-s.gif"'/
c      1234567890123456789012345678901234567890123456789012345
!               1         2         3         4         5
        data end2a_28/'<a href="img/a220506as-b.gif"><img src="img/a2205$
     $06as-s.gif"'/
c     1234567890123456789012345
        data end2b/'alt="station map" width="155" height="152"'/
        data end2c/'border="0"></a> </td></tr>'/
        data begintrc/'<tr align="center">'/
c                   1234567890123456789012345678901234567890123456789012345
        data end3a/'<td colspan="2"><a href="img/a220506t-b.gif"><img sr$
     $c="img/a220506t-s.gif"'/
c                   1234567890123456789012345678901234567890123456789012345
        data end3a_28/'<td colspan="2"><a href="img/a220506at-b.gif"><im$
     $g src="img/a220506at-s.gif"'/
        data end3b/'alt="temperature plot" width="500"'/
        data end3c/'height="244" border="0"></a></td></tr>'/
        data end4/'<td colspan="2">'/
!                  1234567890123456789012345678901234567890123456789012345
        data end5/'<!--#include file="a22table.html" -->'/
        data end6/'</body>'/
        data end7/'</html>'/

        write(6,*)'enter cruise name (p220506) 7 chars'
        read(5,'(a7)') cruise(1:7)
        if(cruise(1:3).eq.'p28') then
          write(6,*) 'please enter again:'
          read(5,'(a8)') cruise8(1:8)
          write(outhtml28(1:8),'(a8)') cruise8(1:8)
        endif
        write(*,*)'cruise=',cruise(1:7)
        write(xbtinfo(9:11),'(a3)') cruise(1:3)
        write(*,*)'xbtinfo=',xbtinfo
        
        call rdxbtinfo1(xbtinfo,cruise,prev,next,iport,linename,
     $                  shipname,cruise8)
        write(*,*)'after rdxbtinfo1 linename=',linename

        write(outhtml(1:7),'(a7)') cruise(1:7)
        if(cruise(1:1).eq.'s') outhtml(1:1) = 'p'
        if(cruise(1:3).eq.'i21') outhtml(1:3) = 'i15'
        write(*,*)'prev=',prev
        write(*,*)'next=',next

        call nameit(cruise,linename,alinename,ip)
        write(*,*)'alinename=',alinename
        write(*,*)'after nameit linename=',linename

        if(cruise(2:3).eq.'22') then
           write(outhtml(1:1),500) 'a'
c width and height of stn map:
           write(end2b(26:28),'(a3)') '155'
           write(end2b(39:41),'(a3)') '152'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '244'
c will probably need multiple mid4 s (AX22 label)
           write(mid4_22(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'05') then
           write(outhtml(1:1),500) 'p'
c width and height of stn map:
           write(end2b(26:28),'(a3)') ' 78'
           write(end2b(39:41),'(a3)') '152'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'

           write(mid4_05(31:32),'(a2)') '05'
           write(mid4_05(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'08') then
           write(outhtml(1:1),500) 'p'
c width and height of stn map:
           write(end2b(26:28),'(a3)') '240'
           write(end2b(39:41),'(a3)') '124'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'

           write(mid4_50(31:32),'(a2)') '08'
           write(mid4_50(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'15') then
           write(outhtml(1:1),500) 'i'
c width and height of stn map:
           write(end2b(26:28),'(a3)') '300'
           write(end2b(39:41),'(a3)') '152'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
c will probably need multiple mid4 s (IX21/IX15 label)
           write(mid4_15(39:42),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'21') then
           write(outhtml(1:1),500) 'i'
c width and height of stn map:
           write(end2b(26:28),'(a3)') '200'
           write(end2b(39:41),'(a3)') '113'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4_21(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'28') then
           write(outhtml28(1:1),500) 'i'
           write(outhtml(1:1),500) 'i'
c           write(top10(20:20),'(a1)') 'i'
c           write(middown1(44:44),'(a1)') 'i'
c           write(middown1(49:49),'(a1)') 'i'
c width and height of stn map:
           write(end2b(26:28),'(a3)') ' 90'
           write(end2b(39:41),'(a3)') '155'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4_28(29:32),'(a4)') 'IX28'
           write(mid4_28(34:38),'(a5)') outhtml28(4:8)
c mid7_28 is previous
        write(mid7_28(10:12),'(a3)') outhtml(1:3)
        write(mid7_28(13:17),'(a5)') prev(1:5)
c mid8_28 is next
        write(mid8_28(10:12),'(a3)') outhtml(1:3)
        write(mid8_28(13:17),'(a5)') next(1:5)

        elseif(cruise(2:3).eq.'31') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '225'
           write(end2b(39:41),'(a3)') '103'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4_30(37:40),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'34') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '240'
           write(end2b(39:41),'(a3)') ' 87'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4_50(31:32),'(a2)') '34'
           write(mid4_50(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(1:3).eq.'s37') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '325'
           write(end2b(39:41),'(a3)') '114'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4s37(40:43),'(a4)') outhtml(4:7)
! watch out for other cruises after this change (5jan2011 LL)
!        data middown1/'<a href="ftp://kakapo.ucsd.edu/pub/www-hrx/ax22/a220311a.10.gz">'/
!                       1234567890123456789012345678901234567890123456789012345678901234
!                                1         2         3         4         5 
!        data middown1/'<a href="../www-hrx/ax22/a220311a.10.gz">'/
!                       123456789012345678901234567890123456789
!                                1         2         3         4         5 
           middown1(21:26) = 'p37s/s'
           middown1(27:32) = outhtml(2:7)
        elseif(cruise(1:3).eq.'p37') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '187'
           write(end2b(39:41),'(a3)') '115'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '252'
           write(mid4_50(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'38') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') ' 84'
           write(end2b(39:41),'(a3)') '155'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '251'
           write(mid4_38(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'50') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '260'
           write(end2b(39:41),'(a3)') '106'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '250'
           write(mid4_50(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'09') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') ' 95'
           write(end2b(39:41),'(a3)') '152'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '251'

        elseif(cruise(2:3).eq.'13') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '200'
           write(end2b(39:41),'(a3)') '113'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '251'
           write(mid4_13(34:37),'(a4)') outhtml(4:7)

        elseif(cruise(2:3).eq.'81') then
c width and height of stn map:
           write(end2b(26:28),'(a3)') '227'
           write(end2b(39:41),'(a3)') '152'
c width and height of tem map:
           write(end3b(31:33),'(a3)') '500'
           write(end3c(9:11),'(a3)') '251'
        endif

c these must be after above if stmt ^
        write(top10(20:22),'(a3)') outhtml(1:3)
        write(end5(20:22),'(a3)') outhtml(1:3)
        if(outhtml(1:3).eq.'s37') then
           write(top10(20:22),'(a3)') 'p37'
           write(end5(20:22),'(a3)') 'p37'
        endif
c this for ax22 maybe for others?:
!        data middown1/'<a href="ftp://kakapo.ucsd.edu/pub/www-hrx/ax22/a220311a.10.gz">'/
!                       1234567890123456789012345678901234567890123456789012345678901234
!                                1         2         3         4         5 
!        data middown1/'<a href="../www-hrx/ax22/a220311a.10.gz">'/
!                       123456789012345678901234567890123456789
!                                1         2         3         4         5 
        if(cruise(1:3).ne.'s37') then
           write(middown1(21:21),'(a1)') outhtml(1:1)
           write(middown1(23:24),'(a2)') outhtml(2:3)
           write(middown1(26:32),'(a7)') outhtml(1:7)
        endif
c hmm mid 4 will change with each line (AX22 vs IX15/IX21 etc)
c get prev and next cruise names from xbtinfo?
c mid7 is previous
        write(mid7(10:12),'(a3)') outhtml(1:3)
        write(mid7(13:16),'(a4)') prev(1:4)
c mid8 is next
        write(mid8(10:12),'(a3)') outhtml(1:3)
        write(mid8(13:16),'(a4)') next(1:4)
c end2a is station
        write(end2a(14:20),'(a7)') outhtml(1:7)
        write(end2a(44:50),'(a7)') outhtml(1:7)   ! filename station img
        if(cruise(1:3).eq.'i21') then
          write(end2a(14:16),'(a3)') 'i21'
          write(end2a(44:46),'(a3)') 'i21'
        endif
        write(end2a_28(14:21),'(a8)') outhtml28(1:8)
        write(end2a_28(45:52),'(a8)') outhtml28(1:8)
c end3a is tem:
        write(end3a(30:36),'(a7)') outhtml(1:7)
        write(end3a(60:66),'(a7)') outhtml(1:7)   ! filename tem img
        if(cruise(1:3).eq.'i21') then
            write(end3a(30:32),'(a3)') 'i21'
            write(end3a(60:62),'(a3)') 'i21'
        endif
        write(end3a_28(30:37),'(a8)') outhtml28(1:8)
        write(end3a_28(61:68),'(a8)') outhtml28(1:8)


        if(cruise(1:3).eq.'p28') then
         open(31,file=outhtml28,status='unknown',form='formatted')
        else
         open(31,file=outhtml,status='unknown',form='formatted')
        endif
500        format(a)
502        format(a,a)
503        format(a,a,a)
504        format(a,a,a,a)
505        format(a,a,a,a,a)
        write(31,500) top1
        write(31,500) top2
        write(31,502) sp,top3
        write(31,502) sp,top4
        write(31,500) top5
        write(31,500) top6
        write(31,500) top7
        write(31,502) sp,top8
        write(31,503) sp,sp,top9
        write(31,503) sp,sp,top10
        write(31,503) sp,sp,endtd
        write(31,502) sp,endtr
        write(31,500) sp,begintr
        write(31,503) sp,sp,top11
        write(31,503) sp,sp,top12
        write(31,503) sp,sp,top13
        write(31,503) sp,sp,endtd
        write(31,500) top14
        write(31,500) top15
        write(31,500) top16
        write(31,500) top17
        write(31,503) sp,top18a, top18b
        write(31,502) sp,begintrl
        write(31,503) sp,sp,mid1
        write(31,504) sp,sp,sp,mid2
        write(31,504) sp,sp,sp,begintr
c WATCH WHICH ONE HERE _ FIX IN FUTURE!
        if(cruise(2:3).eq.'37'.or.cruise(2:3).eq.'15') then
           write(31,505) sp,sp,sp,sp,mid3
        elseif(cruise(2:3).eq.'38') then
           write(31,505) sp,sp,sp,sp,mid3
        elseif(cruise(2:3).eq.'21') then
           write(31,505) sp,sp,sp,sp,mid3
        else
           write(31,505) sp,sp,sp,sp,mid3wid50
        endif
        write(31,505) sp,sp,sp,sp,begintdl

        if(cruise(2:3).eq.'22') then
         write(31,505) sp,sp,sp,sp,mid4_22
        elseif(cruise(2:3).eq.'05') then
         write(31,505) sp,sp,sp,sp,mid4_05
        elseif(cruise(2:3).eq.'08') then
         write(31,505) sp,sp,sp,sp,mid4_50
        elseif(cruise(2:3).eq.'15') then
         write(31,505) sp,sp,sp,sp,mid4_15
        elseif(cruise(2:3).eq.'21') then
         write(31,505) sp,sp,sp,sp,mid4_21
        elseif(cruise(2:3).eq.'28') then
         write(31,505) sp,sp,sp,sp,mid4_28
        elseif(cruise(2:3).eq.'31') then
         write(31,505) sp,sp,sp,sp,mid4_30
        elseif(cruise(2:3).eq.'34') then
         write(31,505) sp,sp,sp,sp,mid4_50
        elseif(cruise(2:3).eq.'37') then
         if(cruise(2:3).eq.'p') then
            write(31,507) sp,sp,sp,sp,mid4a,alinename(1:ip),mid4b
         else
            write(31,507) sp,sp,sp,sp,mid4a,alinename(1:ip),mid4b
         endif
        elseif(cruise(2:3).eq.'38') then
         write(31,505) sp,sp,sp,sp,mid4_38
        elseif(cruise(2:3).eq.'50') then
         write(31,505) sp,sp,sp,sp,mid4_50
        elseif(cruise(2:3).eq.'09') then
         write(31,507) sp,sp,sp,sp,mid4a,alinename(1:ip),mid4b
        elseif(cruise(2:3).eq.'13') then
         write(31,505) sp,sp,sp,sp,mid4_13
        elseif(cruise(2:3).eq.'81') then
         write(31,507) sp,sp,sp,sp,mid4a,alinename(1:ip),mid4b
507        format(a,a,a,a,a,a,a)
        endif

        write(31,505) sp,sp,sp,sp,mid5
        write(31,504) sp,sp,sp,begintr
        write(31,505) sp,sp,sp,sp,mid3
cNO DOWNLOAD lines (3):
!write(31,505) sp,sp,sp,sp,begintdc
!write(31,505) sp,sp,sp,sp,mid6
!write(31,505) sp,sp,sp,sp,mid5

! Download lines (5):
        write(31,505) sp,sp,sp,sp,begintdlc2
        write(31,505) sp,sp,sp,sp,middown1
        write(31,505) sp,sp,sp,sp,middown2
        write(31,505) sp,sp,sp,sp,endtd
        write(31,504) sp,sp,sp,endtr

        write(31,504) sp,sp,sp,begintr
        write(31,504) sp,sp,sp,mid3
        write(31,505) sp,sp,sp,sp,begintdl
c Previous:
        if(cruise(1:3).eq.'p28') then
         write(31,505) sp,sp,sp,sp,mid7_28
        else
         write(31,505) sp,sp,sp,sp,mid7
        endif

        write(31,505) sp,sp,sp,sp,mid5
        write(31,504) sp,sp,sp,begintr
        write(31,505) sp,sp,sp,sp,mid3
        write(31,505) sp,sp,sp,sp,begintdl
c Next:
        if(cruise(1:3).eq.'p28') then
         write(31,505) sp,sp,sp,sp,mid8_28
        else
         write(31,505) sp,sp,sp,sp,mid8
        endif
        write(31,505) sp,sp,sp,sp,mid5
        write(31,504) sp,sp,sp,begintr
        write(31,505) sp,sp,sp,sp,mid3
        write(31,505) sp,sp,sp,sp,begintdc
        write(31,505) sp,sp,sp,sp,mid6
        write(31,505) sp,sp,sp,sp,mid5
        write(31,504) sp,sp,sp,endtable
        write(31,503) sp,sp,endtd

        write(31,500) end1
c Station plot:
        if(cruise(1:3).eq.'p28') then
        write(31,502) sp,end2a_28
        else
        write(31,502) sp,end2a
        endif
        write(31,502) sp,end2b
        write(31,502) sp,end2c
        write(31,500) begintrc
c Tem plot:
        if(cruise(1:3).eq.'p28') then
        write(31,502) sp,end3a_28
        else
        write(31,502) sp,end3a
        endif
        write(31,502) sp,end3b
        write(31,502) sp,end3c
        write(31,500) begintr
        write(31,500) end4
        write(31,500) end5
        write(31,500) endtd
        write(31,500) endtr
        write(31,500) endtable
        write(31,500) endtd
        write(31,500) endtr
        write(31,500) endtable
        write(31,500) end6
        write(31,500) end7

        close(31)
        stop
        end

c-----------------------------------------
        subroutine nameit(cruise,linename,alinename,ip)
c        INPUT: cruise 'p090508'
c               linename integer array 0 or 1  - output of rdxbtinfo1
c        OUTPUT: alinename - character line of appropriate name 'PX06/PX31 0508'
        character*7 cruise
        character*20 alinename
        dimension linename(6)

        write(*,*)'linename=',linename
        ip = 1
        if(cruise(1:3).eq.'p09') then
c write correct line names:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'PX06'
              ip = ip + 4
           endif
        write(*,*)'alinename=',alinename,' ip=',ip
           if(linename(2).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX09'
              ip = ip + 4
           endif
        write(*,*)'alinename=',alinename,' ip=',ip
           if(linename(3).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX39'
              ip = ip + 4
           endif
        write(*,*)'alinename=',alinename,' ip=',ip
           if(linename(4).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX31'
              ip = ip + 4
           endif
        write(*,*)'alinename=',alinename,' ip=',ip
           if(linename(5).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX12'
              ip = ip + 4
           endif
        write(*,*)'alinename=',alinename,' ip=',ip
           if(linename(6).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX18'
              ip = ip + 4
           endif

        elseif(cruise(1:3).eq.'s37') then
           ip = 1
           alinename(ip:ip+9) = 'PX37 South'
           ip = ip + 10
        elseif(cruise(1:3).eq.'p37') then
           ip = 1
           if(linename(3).eq.1) then
              alinename(ip:ip+3) = 'PX37'
              ip = ip + 4
           endif
           if(linename(2).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX10'
              ip = ip + 4
           endif
           if(linename(1).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX37'
              ip = ip + 4
           endif
        elseif(cruise(1:3).eq.'p22') then
           write(*,*)'in nameit p22ip=',ip
        elseif(cruise(1:3).eq.'p13') then
c write correct line name:
           ip = 1
           alinename(ip:ip+3) = 'PX13'
           ip = ip + 4
        elseif(cruise(1:3).eq.'p81') then
c write correct line names:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'PX81'
              ip = ip + 4
           elseif(linename(2).eq.1) then
              alinename(ip:ip+3) = 'PX25'
              ip = ip + 4
           endif
        endif
c put a space after line names:
        alinename(ip:ip) = ' '
        ip = ip + 1
        write(*,*)'in nameit, ip=',ip
        write(*,*)'cruise(4:7)=',cruise(4:7)
c write cruise date next:
        write(alinename(ip:ip+3),'(a4)')  cruise(4:7)
c final length of alinename character array:
        ip = ip+3
        write(*,*)'alinename=',alinename,' ip=',ip
        return
        end
