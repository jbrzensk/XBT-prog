      program ferstn
! use "ferstn.mk" to recompile:
!  make -f ferstn.mk
! 
! 16sep2005 - start mods for www-hrx stn map (new 2005 look)
! ACK - call crsland needs to be updated!!!  28dec00 LL
! writes a ferret control file for stations only
      character path_1*47, path_2*31, plot_xbt*45, fxctd*16
      character*7 acruise, fdat*11, path_3*37, plot_ctd*44
      character*51 path_4
      character*32 pathp28_2, acruisep28*8
      character*52 a22_1, a22_2*47, a22_2a*22, a22_3*52, a22_4*42
      character*11 xbtinfo, alinename*19, shipname*3
      character*5 prev, next
      dimension iport(9), linename(7)
!
      data xbtinfo/'xbtinfo.p09'/
      data alinename/'                   '/
      data fdat/'p819709.dat'/
!                  12345678901
      data fxctd/'xctd/p819709.ctd'/
      data path_1/'file/form="(f8.3,1x,f8.3)"/variables="lat,long"'/
      data path_2/'"/data/xbt/p81/9709/stnpos.fer"'/
!                    123456789012345678901234567890123456789012345678901
      data plot_xbt/'plot/over/vs/symbol=21/i=1:   /nolab long,lat'/
!                      123456789012345678901234567890123456789012345678901
      data path_3/'"/data/xbt/p81/9709/xctd/p819709.ctd"'/
!                    1234567890123456789012345678901234567
      data plot_ctd/'plot/over/vs/symbol=28/i=1:  /nolab long,lat'/
      data path_4/'file/form="(36x,f8.3,1x,f8.3)"/variables="lat,long"'/
      data pathp28_2/'"/data/xbt/p28/9312a/stnpos.fer"'/
!                       12345678901234567890123456789012

! ferret control output file:
       open(55,file='stn.fer',status='unknown',form='formatted')

! get paths correct
       write(6,*)'Enter cruise name (7 chars) (p819709):'
       read(5,'(a7)') acruise
        if(acruise(1:3).eq.'s37') then
          write(xbtinfo(9:11),'(a3)') acruise(1:3)
        elseif(acruise(1:3).eq.'i21') then
          write(xbtinfo(9:11),'(a3)') 'p15'
        elseif(acruise(1:3).eq.'p13') then
          write(xbtinfo(9:11),'(a3)') 'p09'
        else
          write(xbtinfo(10:11),'(a2)') acruise(2:3)
        endif

       if(acruise(2:3).eq.'28') then
        write(6,*)'p28, enter that cruise name again (p289312a) 8 chars'
        read(5,'(a8)') acruisep28
        write(fdat(1:7),'(a7)') acruise(1:7)
        write(fxctd(6:12),'(a7)') acruise(1:7)
        write(pathp28_2(12:14),'(a3)') acruise(1:3)
        write(pathp28_2(16:20),'(a5)') acruisep28(4:8)
       elseif(acruise(2:3).eq.'06') then
        write(6,*)'p06, enter that cruise name again (p060907a) 8 chars'
        read(5,'(a8)') acruisep28
        write(fdat(1:7),'(a7)') acruise(1:7)
        write(fxctd(6:12),'(a7)') acruise(1:7)
        write(pathp28_2(12:14),'(a3)') acruise(1:3)
        write(pathp28_2(16:20),'(a5)') acruisep28(4:8)
! note no xctd in p28
       else
        write(fdat(1:7),'(a7)') acruise(1:7)
        write(fxctd(6:12),'(a7)') acruise(1:7)
!20mar2019: p13 vs p09:
!        write(path_2(12:14),'(a3)') acruise(1:3)
         write(path_2(12:14),'(a3)') xbtinfo(9:11)
        write(path_2(16:19),'(a4)') acruise(4:7)
!20mar2019: p13 vs p09:
!         write(path_3(12:14),'(a3)') acruise(1:3)
        write(path_3(12:14),'(a3)') xbtinfo(9:11)
        write(path_3(16:19),'(a4)') acruise(4:7)
        write(path_3(26:32),'(a7)') acruise(1:7)
       endif

! read "stations.dat" (name appropriate for cruise), find all drops
! marked with a 1 in edit column, write out to file stnpos.fer - that's
! the file we'll read from  - for our ferret plot file of xbt positions.
       open(10,file=fdat,status='old',form='formatted')

! file of xbt position with a 1 in the edit column:
! 15may2008 LL Or 2 in edit col
       open(50,file='stnpos.fer',status='unknown',form='formatted')

       icntedt = 0
       do 11 i = 1, 600
          read(10,520,end=12,err=12) ypos, xpos, iedt
520          format(36x,f8.3,1x,f8.3,7x,i2)
! p22 sometimes uses a 0....
          if(fdat(1:3).eq.'p22'.and.iedt.eq.0) then
             icntedt = icntedt + 1
             write(50,521) ypos, xpos
             go to 9
          endif
          if(iedt.eq.1.or.iedt.eq.2.or.iedt.eq.4) then
             icntedt = icntedt + 1
             write(50,521) ypos, xpos
          endif
9          continue
521          format(f8.3,1x,f8.3)
11       continue
12       continue
       close(10)
       close(50)

       if(icntedt.le.9) then
          write(plot_xbt(30:30),'(i1)') icntedt
       elseif(icntedt.ge.10.and.icntedt.le.99) then
          write(plot_xbt(29:30),'(i2)') icntedt
       elseif(icntedt.ge.100) then
          write(plot_xbt(28:30),'(i3)') icntedt
       endif

! Let's see if we have xctd positions:
       ihavxctd = 0
       if(acruise(2:3).eq.'28') go to 40
       open(20,file=fxctd,status='old',form='formatted',err=40)
! ok, if we don't err out to 40, we xctd positions
       ihavxctd = 1
! read um to count
       icntxctd = 0
       do 30 i = 1, 100
          read(20,530,end=31,err=31) ypos, xpos
530          format(36x,f8.3,1x,f8.3)
          icntxctd = icntxctd + 1
30       continue
31       continue
       if(icntxctd.le.9) then
          write(plot_ctd(29:29),'(i1)') icntxctd
       elseif(icntxctd.ge.10.and.icntxctd.le.99) then
          write(plot_ctd(28:29),'(i2)') icntxctd
       endif

40       continue

! 16sep 2005 NO MOR - put in each section...  argh.
! Begin writing ferret control file for xbt/xctd station positions:
! next 6 lines common to all cruise lines
! 19jun2001 LL       write(55,'(a14)')'PPL DFLTFNT CR'
! FIX FOR ALL 20sep2005 LL
!        write(55,'(a14)')'PPL DFLTFNT DR'
!        write(55,'(a19)')'ppl axlsze 0.20,.20'
!        write(55,'(a17)')'ppl axset 1,1,1,1'
!        write(55,'(a11)')'ppl pen 0,1'
!        write(55,'(a11)')'ppl pen 1,7'
!        write(55,'(a22)')'ppl labset .2,.2,.2,.2'
!        write(55,*)

! read info from appropriate xbtinfo file:
       call rdxbtinfo1(xbtinfo,acruise,prev,next,iport,linename,
     $                 shipname,acruisep28)
        write(*,*)'rtn rdxbtinfo1, linename=',linename

! this if then, elseif then, etc has a section for each cruise line,
! some stuff is identical, but it seemed easier to finish writing the
! ferret file here

! p08 new I think
       if(acruise(1:3).eq.'p08') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.15,.15'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .18,.18,.18,.18'
           write(55,'(a)') 'set win/asp=0.65'
           write(55,'(a)') 'set region/x=165E:285E/y=50S:10N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
          if(iport(1).eq.1) then
           write(55,'(a)') 'label 179.0,-49.1,0,0,.18 Dunedin'
          endif
          if(iport(2).eq.1) then
           write(55,'(a)') 'label 269.0,6.5,0,0,.18 Panama'
          endif
          if(iport(3).eq.1) then
           write(55,'(a)') 'label 187.0,-38.0,0,0,.18 Auckland'
          endif
! write linename:
            write(55,'(a,a4)') 'label 177.0,5.0,0,0,.18 PX08 ',
     $                       acruise(4:7)

! p09 (14nov2005 LL - mostly working for new format www-hrx...)
!20mar2019       elseif(acruise(1:3).eq.'p09') then
       elseif(xbtinfo(9:11).eq.'p09') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=1.70'
           write(55,'(a)') 'set region/x=170E:245E/y=40S:50N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'

! write correct port names for each cruise:
          if(iport(1).eq.1) then
           write(55,'(a)') 'label 180.0,-37.5,-1,0,.20 Auckland'
          endif
          if(iport(2).eq.1) then
           write(55,'(a)') 'label 180.0,-37.5,-1,0,.20 East Cape'
          endif
! write Hawaii and Suva no matter what:
          write(55,'(a)') 'label 185,20,-1,0,.20 Hawaii'
          write(55,'(a)') 'label 171.,-15,-1,0,.20 Suva'
          if(iport(5).eq.1) then
           write(55,'(a)') 'label 215,47,-1,.20,Seattle'
          endif
          if(iport(6).eq.1) then
           write(55,'(a)') 'label 229,37,-1,.20,SF'
          endif
          if(iport(7).eq.1) then
           write(55,'(a)') 'label 211,32.5,-1,.20,Los Angeles'
          endif
          if(iport(8).eq.1) then
           write(55,'(a)') 'label 214,-19,-1,.20,Tahiti'
          endif
          if(iport(9).eq.1) then
           write(55,'(a)') 'label 180,-37.5,-1,.20,Tauranga'
          endif
! write correct line names on top of stn map:
          ip = 1
          if(linename(1).eq.1) then
             alinename(ip:ip+3) = 'PX06'
              ip = ip + 4
           endif
          if(linename(2).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX09'
              ip = ip + 4
           endif
          if(linename(3).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX39'
              ip = ip + 4
           endif
          if(linename(4).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX31'
              ip = ip + 4
           endif
          if(linename(5).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX12'
              ip = ip + 4
           endif
          if(linename(6).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX18'
              ip = ip + 4
           endif
          if(linename(7).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
             alinename(ip:ip+3) = 'PX13'
              ip = ip + 4
           endif

           write(55,'(a,a)') 'label 171.0,47.0,-1,0,.20, ', 
     $                        alinename(1:ip)
           write(55,'(a,a4,a1)') 'label 171.0,43.5,-1,0,.20, "',
     $          acruise(4:7),'"'

! p15   16sep2005 -set up for new www-hrx:
       elseif(acruise(2:3).eq.'15') then
          write(55,'(a)') 'PPL DFLTFNT DR'
          write(55,'(a)') 'ppl axlsze 0.18,.18'
          write(55,'(a)') 'ppl pen 0,13'
          write(55,'(a)') 'ppl pen 1,13'
          write(55,'(a)') 'ppl labset .20,.20,.20,.20'
          write(55,'(a)') 'set win/asp=0.45'
          if(iport(3).eq.1) then
             write(55,'(a)') 'set region/x=20E:120E/y=15S:40S'
          elseif(iport(6).eq.1) then
             write(55,'(a)') 'set region/x=20E:120E/y=15S:42S'
          elseif(iport(7).eq.1) then
             write(55,'(a)') 'set region/x=20E:145E/y=15S:42S'
          endif
          write(55,'(a)') 'set data/save'
          write(55,'(a)') 'ppl axlabp -1, 1'
          write(55,'(a)') 'ppl axlint 2, 2'
          write(55,'(a)') 'set data "../../etopo5.nc"'
          a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
          a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
          write(55,'(a,a,a)') a22_1, a22_2, a22_2a
          write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
          write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
          write(55,'(a)') 'ppl fill'
          a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
          a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
          write(55,'(a,a,a)') a22_3, a22_4, a22_2a
          write(55,'(a)') 'sh data'
          write(55,'(a)') 'set mode/last verify'

! write Cape of Good Hope on all:
          write(55,'(a)') 'label 20.5,-37.0,-1,0,.20,Cape of Good Hope'
           if(iport(2).eq.1) then
           write(55,'(a)') 'label 22.0,-29.0,-1,0,.20,Durban'
           endif
           if(iport(3).eq.1) then
           write(55,'(a)') 'label 101.0,-34.5,-1,0,.20,Fremantle'
           endif
           if(iport(4).eq.1) then
           write(55,'(a)') 'label 56.0,-19.0,-1,0,.20,Mauritius'
           endif
           if(iport(7).eq.1) then
           write(55,'(a)') 'label 128.0,-38.0,-1,0,.20,Melbourne'
           endif
! write correct line names on top of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'IX21'
              ip = ip + 4
           endif
           if(linename(2).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'IX15'
              ip = ip + 4
           endif
           if(linename(3).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'IX02'
              ip = ip + 4
           endif
           if(linename(4).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'IX31'
              ip = ip + 4
           endif
           write(55,'(a,a)') 'label 84.0,-17.3,-1,0,.20, ',
     $                        alinename(1:ip)
           write(55,'(a,a4,a1)') 'label 112.0,-17.3,-1,0,.20, "',
     $          acruise(4:7),'"'

       elseif(acruise(2:3).eq.'21') then
          write(55,'(a)') 'PPL DFLTFNT DR'
          write(55,'(a)') 'ppl axlsze 0.18,.18'
          write(55,'(a)') 'ppl pen 0,13'
          write(55,'(a)') 'ppl pen 1,13'
          write(55,'(a)') 'ppl labset .20,.20,.20,.20'
          write(55,'(a)') 'set win/asp=0.70'
! generic i21:
          write(55,'(a)') 'set region/x=23E:60E/y=18S:36S'
          write(55,'(a)') 'set data/save'
          write(55,'(a)') 'ppl axlabp -1, 1'
          write(55,'(a)') 'ppl axlint 2, 2'
          write(55,'(a)') 'set data "../../etopo5.nc"'
          a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
          a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
          a22_2a='overlay|basemap>  rose'
          write(55,'(a,a,a)') a22_1, a22_2, a22_2a
          write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
          write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
          write(55,'(a)') 'ppl fill'
          a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
          a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
          write(55,'(a,a,a)') a22_3, a22_4, a22_2a
          write(55,'(a)') 'sh data'
          write(55,'(a)') 'set mode/last verify'

          write(55,'(a)') 'label 25.0,-35.3,-1,0,.20,Port Elizabeth'
           write(55,'(a)') 'label 26.8,-29.0,-1,0,.20,Durban'
           write(55,'(a)') 'label 53.0,-19.5,-1,0,.20,Mauritius'
           write(55,'(a)') 'label 51.0,-35.3,-1,0,.20, IX21'
           write(55,'(a,a4,a1)') 'label 55.0,-35.3,-1,0,.20, "',
     $          acruise(4:7),'"'
! p22
! 04dec2012 LL match p221106
       elseif(acruise(1:3).eq.'p22') then
          write(55,'(a)') 'PPL DFLTFNT DR'
          write(55,'(a)') 'ppl axlsze 0.20,.20'
          write(55,'(a)') 'ppl axset 1,1,1,1'
          write(55,'(a)') 'ppl pen 0,13'
          write(55,'(a)') 'ppl pen 1,13'
          write(55,'(a)') 'ppl labset .20,.20,.20,.20'
          write(55,'(a)') 'set win/asp=1.1'
          write(55,'(a)') 'set region/x=294E:305E/y=53S:66S'
          write(55,'(a)') 'set data/save'
          write(55,'(a)') 'ppl axlint 3, 2'
          write(55,'(a)') 'set data "../../etopo5.cdf"'

          a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
          a22_2='palette=$2"lightgreyscale"$3"/overlay|overlay>/'
           a22_2a='overlay|basemap>" bath'
          write(55,'(a,a,a)') a22_1, a22_2, a22_2a

          write(55,'(a)') 'ppl xfor, (i6,''''lone'''')'
          write(55,'(a)') 'ppl yfor, (i6,''''lat'''')'
          write(55,'(a)') 'ppl fill'

          a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
          a22_4='=$2"dark_terrestrial"$3"/overlay|overlay>|overlay>/'
          write(55,'(a,a,a)') a22_3, a22_4, a22_2a

          write(55,'(a)') 'sh data'
          write(55,'(a)') 'set mode/last verify'

          write(55,'(a)') 'label 294.5,-53.9,-1,0,.25,Isla de los'
          write(55,'(a)') 'label 295.0,-54.4,-1,0,.25,Estados'
          write(55,'(a)') 'label 301.0,-62.9,-1,0,.25,King George'

          write(55,'(a)') 'label 294.5,-65.7,-1,0,.25,Palmer Station'
          write(55,'(a)') 'label 298.0,-64.4,-1,0,.25,Smith Island'
          write(55,'(a,a4)') 'label 301.4,-53.8,-1,0,.24,AX22 ',
     $          acruise(4:7)
! Janet uses symbol=25:
           plot_xbt(21:22) = '25'
! p28
       elseif(acruise(1:3).eq.'p28') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .18,.18,.18,.18'
           write(55,'(a)') 'set win/asp=1.80'
           write(55,'(a)') 'set region/x=136E:152E/y=42S:68S'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
! write correct port names for each cruise:
           write(55,'(a)') 'label 144.0,-44.0,0,0,.17 Hobart'
           write(55,'(a)') 'label 148,-66.0,0,0,.17 Dumont d''''Urville'
           write(55,'(a)') 'label 147.5,-66.8,0,0,.17 Station,'
           write(55,'(a)') 'label 149,-67.6,0,0,.17 Antarctica'
! write correct line names on botton of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'IX28'
              ip = ip + 3
           endif
           write(55,'(a,a4,a1,a5)') 'label 139.0,-43.0,0,0,.20, ',
     $                        'IX28',' ',acruisep28(4:8)
!does not work:     $                        alinename(1:ip),' ',acruisep28(4:8)
! p06:
        elseif(acruise(1:3).eq.'p06') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=1.30'
           write(55,'(a)') 'set region/x=162E:182E/y=42S:14S'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
! write correct port names for each cruise:
           write(55,'(a)') 'label 163.9,-23.0,0,0,.17, Noumea'
           if(iport(1).eq.1) then
             write(55,'(a)') 'label 172.0,-37.0,0,0,.17, Auckland'
           endif
           if(iport(2).eq.1) then
             write(55,'(a)') 'label 175.5,-17.5,0,0,.17, Lautoka'
           elseif(iport(3).eq.1) then
             write(55,'(a)') 'label 177.9,-20.0,0,0,.17, Suva'
           endif
! write correct line names on top of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+4) = 'PX06'
              ip = ip + 4
           endif
           write(55,'(a,a7,a1,a5)') 'label 165.7,-25.5,-1,0,.20, ',
     $                        alinename(1:ip),' ',acruisep28(4:8)

! p30/31
       elseif(acruise(1:3).eq.'p31') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.60'
           write(55,'(a)') 'set region/x=152E:179E/y=28S:16S'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
! write correct port names for each cruise:
! always write Brisbane and Noumea:
           write(55,'(a)') 'label 155.0,-27.6,0,0,.17, Brisbane'
           write(55,'(a)') 'label 163.8,-22.2,0,0,.17, Noumea'
           if(iport(2).eq.1) then
             write(55,'(a)') 'label 175.5,-17.5,0,0,.17, Lautoka'
           elseif(iport(3).eq.1) then
             write(55,'(a)') 'label 177.9,-20.0,0,0,.17, Suva'
           endif
! write correct line names on top of stn map:
           ip = 1
           write(*,*)'linename(1)=',linename(1)
           if(linename(1).eq.1) then
              alinename(ip:ip+6) = 'PX30/31'
              ip = ip + 6
           endif
           write(*,*)'alinename(1:ip)=',alinename(1:ip)
           write(55,'(a,a7,a1,a4)') 'label 152.4,-17.0,-1,0,.20, ',
     $                        alinename(1:ip),' ',acruise(4:7)
! p34
       elseif(acruise(1:3).eq.'p34') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.50'
           write(55,'(a)') 'set region/x=150E:175E/y=42S:32S'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
! write correct port names for each cruise:
! always write Wellington and Sydney
           write(55,'(a)') 'label 151.6,-33.4,0,0,.17 Sydney'
           write(55,'(a)') 'label 172.2,-41.4,0,0,.17,Wellington'
! write correct line names on botton of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'PX34'
              ip = ip + 3
           endif
           write(55,'(a,a4,a1,a4)') 'label 152.2,-41.6,0,0,.20, ',
     $                        alinename(1:ip),' ',acruise(4:7)

       elseif(acruise(1:3).eq.'s37') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.48'
           write(55,'(a)') 'set region/x=200E:245E/y=20N:35N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
           write(55,'(a)') 'label 231.7,33.4,-1,0,.20 Long Beach'
           write(55,'(a)') 'label 204.5,20.5,-1,0,.20 Hawaii'
! write correct line names on top of stn map:
           ip = 1
           alinename(ip:ip+9) = 'PX37 South'
           ip = ip + 10
           write(55,'(a,a)') 'label 201.0,33.0,-1,0,.20, ',
     $                        alinename(1:ip)
           write(55,'(a,a4,a1)') 'label 201.0,31.5,-1,0,.20, "',
     $          acruise(4:7),'"'

       elseif(acruise(1:3).eq.'p37') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.40'
           write(55,'(a)') 'set region/x=110E:240E/y=10N:40N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
           if(iport(1).eq.1) then
             write(55,'(a)') 'label 212.8,37.5,-1,0,.20 San Francisco'
           endif
           if(iport(2).eq.1) then
             write(55,'(a)') 'label 206,19,-1,0,.20 Hawaii'
           endif
           if(iport(3).eq.1) then
             write(55,'(a)') 'label 145,11,-1,0,.20,Guam'
           endif
           if(iport(4).eq.1) then
             write(55,'(a)') 'label 119.5,23.5,-1,0,.20,Taiwan'
           endif
           if(iport(5).eq.1) then
             write(55,'(a)') 'label 110.1,26.0,-1,0,.20,Hong'
             write(55,'(a)') 'label 110.8,23.5,-1,0,.20,Kong'
           endif
c write correct line names on top of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'PX44'
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
           if(linename(3).eq.1) then
              if(ip.ne.1) then
                 alinename(ip:ip) = '/'
                 ip = ip + 1
              endif
              alinename(ip:ip+3) = 'PX37'
              ip = ip + 4
           endif
           write(55,'(a,a)') 'label 145.0,37.2,-1,0,.20, ',
     $                        alinename(1:ip)
           write(55,'(a,a4,a1)') 'label 175.0,37.2,-1,0,.20, "',
     $          acruise(4:7),'"'

c p38 29nov2005 new www-hrx:
       elseif(acruise(1:3).eq.'p38') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.20,.20'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .22,.22,.22,.22'
           write(55,'(a)') 'set win/asp=1.90'
           write(55,'(a)') 'set region/x=165W:140W/y=20N:62N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 3, 1'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'

c write Hawaii no matter what:
           write(55,'(a)') 'label 203,21.5,-1,0,.20 Hawaii'

c write correct port names for each cruise:
           if(iport(2).eq.1) then
            write(55,'(a)') 'label 214,61,-1,0,.20 Valdez'
           endif
           if(iport(3).eq.1) then
            write(55,'(a)') 'label 202,57.5,-1,0,.20 Kodiak'
           endif
           if(iport(4).eq.1) then
            write(55,'(a)') 'label 202,57.5,-1,0,.20 Homer'
           endif

c write linename:
            write(55,'(a)') 'label 214.0,23.0,-1,0,.26 PX38'

            write(55,'(a,a4,a)')
     $       'label 214.0,21.0,-1,0,.26, "', acruise(4:7),'"'
! add p40 12dec2012 LL
       elseif(acruise(1:3).eq.'p40') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.57'
           write(55,'(a)') 'set region/x=135E:205E/y=16N:40N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'
           write(55,'(a)') 'label 135.5,31.4,-1,0,.20 Yokohama'
           write(55,'(a)') 'label 196.5,18.5,-1,0,.20 Hawaii'
! write correct line names on top of stn map:
           ip = 1
           alinename(ip:ip+4) = 'PX40'
           ip = ip + 5
           write(55,'(a,a)') 'label 197.0,37.5,-1,0,.20, ',
     $                        alinename(1:ip)
           write(55,'(a,a4,a1)') 'label 197.0,35.2,-1,0,.20, "',
     $          acruise(4:7),'"'

c p50 start working on 25oct2005
       elseif(acruise(1:3).eq.'p50') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.55'
           write(55,'(a)') 'set region/x=170E:290E/y=55S:10S'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'

          write(55,'(a)') 'label 172,-32.0,-1,0,.20 Auckland'
          write(55,'(a)') 'label 172,-49.0,-1,0,.20 Lyttelton'
          write(55,'(a)') 'label 280,-40,0,-1,.20,Valparaiso'
          write(55,'(a)') 'label 275,-13,0,-1,.20,Callao'
       write(*,*) acruise(4:7)
           write(55,'(a,a4)') 'label 172.0,-14.0,-1,0,.20,PX50 ',
     $                          acruise(4:7)
       write(*,*) 'end', acruise(4:7)
c p81 (& px25) 6jan2006 - working on new format:
       elseif(acruise(1:3).eq.'p81') then
           write(55,'(a)') 'PPL DFLTFNT DR'
           write(55,'(a)') 'ppl axlsze 0.18,.18'
           write(55,'(a)') 'ppl pen 0,13'
           write(55,'(a)') 'ppl pen 1,13'
           write(55,'(a)') 'ppl labset .20,.20,.20,.20'
           write(55,'(a)') 'set win/asp=0.80'
           write(55,'(a)') 'set region/x=130E:290E/y=45S:45N'
           write(55,'(a)') 'set data/save'
           write(55,'(a)') 'ppl axlabp -1, 1'
           write(55,'(a)') 'ppl axlint 2, 2'
           write(55,'(a)') 'set data "../../etopo5.nc"'
           a22_1='contour/set/fill/nolab/nokey/lev=(-200,10000,10000)/'
           a22_2='palette=  "lightgreyscale"   /overlay|overlay>/'
           a22_2a='overlay|basemap>  rose'
           write(55,'(a,a,a)') a22_1, a22_2, a22_2a
           write(55,'(a)') 'ppl xfor, (i4,''''lone'''')'
           write(55,'(a)') 'ppl yfor, (i4,''''lat'''')'
           write(55,'(a)') 'ppl fill'
           a22_3='contour/fill/nolab/nokey/lev=(0,10000,10000)/palette'
           a22_4='=  "dark_terrestrial"   /overlay|overlay>/'
           write(55,'(a,a,a)') a22_3, a22_4, a22_2a
           write(55,'(a)') 'sh data'
           write(55,'(a)') 'set mode/last verify'

! write correct port names for each cruise:
! always write Hawaii:
           write(55,'(a)') 'label 206,20,-1,0,.20 Hawaii'

           if(iport(3).eq.1) then
            write(55,'(a)') 'label 147,40.5,-1,0,.20,Hachinohe'
           endif
           if(iport(4).eq.1) then
            write(55,'(a)') 'label 130.5,25.5,-1,0,.20,Hiroshima'
           endif
           if(iport(5).eq.1) then
            write(55,'(a)') 'label 260,-42,-1,0,.20,Coronel'
           endif
           if(iport(6).eq.1) then
            write(55,'(a)') 'label 240,-42.5,-1,0,.20,Puerto Montt'
           endif
! write correct line names on top of stn map:
           ip = 1
           if(linename(1).eq.1) then
              alinename(ip:ip+3) = 'PX81'
              ip = ip + 4
           elseif(linename(2).eq.1) then
              alinename(ip:ip+3) = 'PX25'
              ip = ip + 4
           endif
           write(55,'(a,a4,a1,a4)') 'label 200.0,40.0,-1,0,.20, ',
     $                        alinename(1:ip),' ',acruise(4:7)

       endif

! the plot_xbt line
! path to xbt station positions:
! p28 different path since a,b,c, etc is actually in path,
       if(acruise(1:3).eq.'p28'.or.acruise(1:3).eq.'p06') then
          write(55,'(a47,1x,a32)') path_1(1:47), pathp28_2(1:32)
          write(55,'(a45)') plot_xbt
       else
          write(55,'(a47,1x,a31)') path_1, path_2
          write(55,'(a45)') plot_xbt
       endif

! xctds:
! 04dec2012 LL skip p22 ctd's for now...
        if(acruise(1:3).eq.'p22') go to 578
       if(ihavxctd.eq.1) then
c path to xctd station positions:
          write(55,'(a51,1x,a37)') path_4, path_3
c plot xctd line
          write(55,'(a44)') plot_ctd
       endif

! output gif file:
! skip this - using metafile to ps
!       write(55,'(a16)') 'frame/format=gif'
578     continue
       close(55)
       stop
       end

       subroutine crs_lnd
          write(55,'(a11)') 'ppl cross,1'
          write(55,'(a17)') 'go fland 20 green'
          write(55,'(a9)') 'go land 1'
       return
       end
