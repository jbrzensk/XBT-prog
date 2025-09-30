! search for CHECK!!!!!!
        program mapxbt3
! 17jan2013 LL increased array size from 400 to 600 for large atlantic transects.
!   also (iw=1, write lots, =0 write min to mapxbt3.log)500
! use make -f mapxbt3.mk
! must link with subroutine fertem.f !!
!
! current limits are 90 depth points, 300 stations, and 36 nearest points
! for the objective mapping.
! 
! searches for p09 or p38 to run by latitude
!
        dimension c2(36),grid(1500,1),tbar(1),w4(36,1),asi(666),as3(666)
        dimension xtmp(90)
        common sdata(90,600,1),dis(600),dep(105),x(6,6),y(6,6),z(6,6,1),
     *  z1(36,1),xpos(36),ypos(36)
        common /count/nx,ny,xt,xg,yg,nyd,nxd,nyg,nxg,nvar,nyet,nmaps
        character fnam*12,cr*2,ofil*12,typ*3, shipname*30, ship2*20
        character*3 orient
        character*17 fargo
        character xbtinfo*11, acruise*7, prev*5, next*5
        character ashipname*3
        dimension iport(9),linename(6)
        dimension dis1(600)

        data xbtinfo/'xbtinfo.p09'/
        data fnam/'p099105a.10 '/
        data ofil/'p099105a.tem'/
        data fargo/'p371110a.10s_argo'/
!        data ytop/0./,dely/10./,xmin/0./,xmax/360./,deltax/.10/
! xmax gt 360 for atlantic....
        data ytop/0./,dely/10./,xmin/0./,xmax/380./,deltax/.10/
        data ivav/5/,ybot/850./, orient/'lat'/
!       data shipname/'                    '/
        data ship2/'                    '/
        data evar/.1/,yscale/1./,efold2/4./,itest/0/
! iw = 0 minimal output to mapxbt3.log, =1 max output...
        iw = 0

        open(33,file='mapxbt3.log',status='unknown',form='formatted')

        write(*,*)' Enter .10 filename : (ie, p099105a) (8 chars!)'
        read(5,'(a8)') fnam(1:8)
        fargo(1:8) = fnam(1:8)
        write(*,*) 'fnam=', fnam(1:8)
        if(fnam(1:3).eq.'p81') fnam(8:8) = 'a'

        acruise(1:7) = fnam(1:7)
        write(xbtinfo(9:11),'(a3)') acruise(1:3)
        if(acruise(1:3).eq.'p13') xbtinfo(9:11) = 'p09'
        write(*,*) 'xbtinfo=', xbtinfo

! CHECK
        if(fnam(1:3).eq.'p22') then
           write(*,*)' Enter ybot for p22 '
           write(*,*)' 1) 760             '
           write(*,*)' 2) 800             '
           write(*,*)' 3) 850             '
           read(5,*) iybot
           if(iybot.eq.1) then
              ybot = 760.0
           elseif(iybot.eq.2) then
              ybot = 800.0
           elseif(iybot.eq.3) then
              ybot = 850.0
           endif
        endif
        write(*,*)' Enter grid type:(tem or del or sal)'
        read(5,'(a3)') typ
        write(*,*) 'typ=',typ
! output filename: add last 3 chars deeper in prog:
        ofil(1:8)=fnam(1:8)
        ofil(10:12)=typ(1:3)
!
! only need shipname for tem ferret plot
        if(typ.eq.'tem') then

c 13jan2006- start adding rdxbtinfo1 for p81 only:
           if(fnam(1:3).eq.'p81') then
c read info from appropriate xbtinfo file:
            call rdxbtinfo1(xbtinfo,acruise,prev,next,iport,linename,
     $                 ashipname)
            call decodeship(ashipname, shipname, ierr,l2)
            write(*,*)'ierr=',ierr
            if(ierr.eq.0) go to 10
          endif

1          write(*,*)' Ship name is (enter number):'
          write(*,*)' 1 - Argentina Star      (p09)
     $ |   34 - Marine Columbia (p38)'
          write(*,*)' 2 - Astrolabe           (p28)
     $ |   35 - MSC Federica    (i15)'
          write(*,*)' 3 - Fua Kavenga         (p31)
     $ |   36 - Horizon Enterprise(p37)'
          write(*,*)' 4 - Iron Dampier        (p34)
     $ |   37 - Forestal Diamante (p81)'
          write(*,*)' 5 - Rangitane           (p34)
     $ |   38 - Nedlloyd Wellington (p34)'
          write(*,*)' 6 - Rangitata           (p34)
     $ |   39 - Seabulk Pride (p38)'
          write(*,*)' 7 - Ranginui            (p34)
     $ |   40 - Maersk Auckland (p09)'
          write(*,*)' 8 - Sealand Enterprise  (p37)
     $ |   41 - Direct Condor   (p09)'
          write(*,*)' 9 - Tonsina             (p38)
     $ |   42 - USCG Hickory    (p38)'
          write(*,*)'10 - Chevron Mississippi (p38)
     $ |   43 - Maersk Denton   (p08)'
          write(*,*)'11 - Asian Challenger    (p50)
     $ |   44 - Polar Endeavour (p38)'
          write(*,*)'12 - NYK Nacre           (p81)
     $ |   45 - Vega Gotland    (p34)'
          write(*,*)'13 - Rangiora            (p34)
     $ |   46 - Nora Maersk     (p08)'
          write(*,*)'14 - Lydia Oldendorff    (p50)
     $ |   47 - Safmarine Meru  (i21)'
          write(*,*)'15 - CSX Enterprise      (p37) (p370005 & beyond)'
          write(*,*)'16 - Columbus Coromandel (p09)
     $ |   48 - Horizon Hawk    (p37)'
          write(*,*)'17 - LMGould             (p22)
     $ |   49 - CMA CGM Lavender(p15)'
          write(*,*)'18 - Wellington Express  (p34)
     $ |   50 - E.R.Wilhelmshaven(09)'
          write(*,*)'19 - Kakapo Chief        (p30)
     $ |   51 - R/V Melville'
          write(*,*)'20 - Columbus Florida    (p09)
     $ |   52 - Josephine Maersk(p08)'
          write(*,*)'21 - MOL Kauri           (p50)
     $ |   53 - Horizon Spirit (p37s)'
          write(*,*)'22 - Forum Samoa 2       (p31)
     $ |   54 - Southern Surveyor(p34)'
          write(*,*)'23 - M/V Polar Duke      (p22)
     $ |   55 - USCG Spar (p38) '
          write(*,*)'24 - Nathaniel B. Palmer (p22)
     $ |   56 - MSC Hobart (p34)'
          write(*,*)'25 - Overseas Boston     (p38)
     $ |   57 - Maersk Phuket (p09)'
          write(*,*)'26 - Capitaine Tasman    (p31)
     $ |   58 - Maersk Fuji (p06)'
          write(*,*)'27 - Coral Chief         (p34)
     $ |   59 - Cap Reinga (p09) '
          write(*,*)'28 - Conti Asia          (p50)
     $ |   60 - JPO Scorpius (p09)'
          write(*,*)'29 - Nedlloyd Nelson     (p34)
     $ |   61 - Maersk Fukuoka (p06)'
          write(*,*)'30 - New Plymouth        (p34)
     $ |   62 - BC San Francisco (p06)'
          write(*,*)'31 - PONL  Mairangi      (p08)
     $ |   63 - JRS Canis  (p40) '
          write(*,*)'32 - ANL  Progress       (p34)
     $ |   64 - Shengking (p31)  '
          write(*,*)'33 - Direct Tui          (p09)
     $ |   65 - Maersk Senang (i21)'
          write(*,*)' 0 - leave blank!             
     $ |   66 - MELL Springwood (p44)'
          write(*,*)'                              
     $ |   67 - MSC Vienna (i21)     '
          write(*,*)'                              
     $ |   68 - MSC Damla  (i21)     '
          write(*,*)'                              
     $ |   69 - Safmarine Mulanje (p05)     '
          read(5,*) iship
          if(iship.eq.0) then
!             write(*,*) 'Enter ship name: (up to 19 characters) '
!             write(*,*) 'If there is a space in the name use the dash (-)'
!             write(*,*) 'character for the space!'
!             read(5,*) shipname
             shipname(1:16) = '                '
             l2 = 16
          elseif(iship.eq.1) then
             shipname(1:16) = 'Argentina Star, '
             l2 = 16
          elseif(iship.eq.2) then
             shipname(1:11) = 'Astrolabe, '
             l2 = 11
          elseif(iship.eq.3) then
             shipname(1:13) = 'Fua Kavenga, '
             l2 = 13
          elseif(iship.eq.4) then
             shipname(1:14) = 'Iron Dampier, '
             l2 = 14
          elseif(iship.eq.5) then
             shipname(1:11) = 'Rangitane, '
             l2 = 11
          elseif(iship.eq.6) then
             shipname(1:11) = 'Rangitata, '
             l2 = 11
          elseif(iship.eq.7) then
             shipname(1:10) = 'Ranginui, '
             l2 = 10
          elseif(iship.eq.8) then
             shipname(1:21) = 'Sea-Land Enterprise, '
             l2 = 21
          elseif(iship.eq.9) then
             shipname(1:10) = 'Tonsina, '
             l2 = 10
          elseif(iship.eq.10) then
             shipname(1:21) = 'Chevron Mississippi, '
             l2 = 21
          elseif(iship.eq.11) then
             shipname(1:18) = 'Asian Challenger, '
             l2 = 18
          elseif(iship.eq.12) then
             shipname(1:11) = 'NYK Nacre, '
             l2 = 11
          elseif(iship.eq.13) then
             shipname(1:10) = 'Rangiora, '
             l2 = 10
          elseif(iship.eq.14) then
             shipname(1:18) = 'Lydia Oldendorff, '
             l2 = 18
          elseif(iship.eq.15) then
             shipname(1:17) = 'CSX Enterprise, '
             l2 = 17
          elseif(iship.eq.16) then
             shipname(1:21) = 'Columbus Coromandel, '
             l2 = 21
          elseif(iship.eq.17) then
             shipname(1:9) = 'LMGould, '
             l2 = 9
          elseif(iship.eq.18) then
             shipname(1:20) = 'Wellington Express, '
             l2 = 20
          elseif(iship.eq.19) then
             shipname(1:14) = 'Kakapo Chief, '
             l2 = 14
          elseif(iship.eq.20) then
             shipname(1:18) = 'Columbus Florida, '
             l2 = 18
          elseif(iship.eq.21) then
             shipname(1:11) = 'MOL Kauri, '
             l2 = 11
          elseif(iship.eq.22) then
             shipname(1:15) = 'Forum Samoa 2, '
             l2 = 15
          elseif(iship.eq.23) then
             shipname(1:16) = 'M/V Polar Duke, '
             l2 = 16
          elseif(iship.eq.24) then
             shipname(1:21) = 'Nathaniel B Palmer, '
             l2 = 21
          elseif(iship.eq.25) then
             shipname(1:17) = 'Overseas Boston, '
             l2 = 17
          elseif(iship.eq.26) then
             shipname(1:18) = 'Capitaine Tasman, '
             l2 = 18
          elseif(iship.eq.27) then
             shipname(1:13) = 'Coral Chief, '
             l2 = 13
          elseif(iship.eq.28) then
             shipname(1:12) = 'Conti Asia, '
             l2 = 12
          elseif(iship.eq.29) then
             shipname(1:17) = 'Nedlloyd Nelson, '
             l2 = 17
          elseif(iship.eq.30) then
             shipname(1:14) = 'New Plymouth, '
             l2 = 14
          elseif(iship.eq.31) then
             shipname(1:15) = 'PONL Mairangi, '
             l2 = 15
          elseif(iship.eq.32) then
             shipname(1:14) = 'ANL Progress, '
             l2 = 14
          elseif(iship.eq.33) then
             shipname(1:12) = 'Direct Tui, '
             l2 = 12
          elseif(iship.eq.34) then
             shipname(1:17) = 'Marine Columbia, '
             l2 = 17
          elseif(iship.eq.35) then
             shipname(1:14) = 'MSC Federica, '
             l2 = 14
          elseif(iship.eq.36) then
             shipname(1:20) = 'Horizon Enterprise, '
             l2 = 20
          elseif(iship.eq.37) then
             shipname(1:19) = 'Forestal Diamante, '
             l2 = 19
          elseif(iship.eq.38) then
             shipname(1:21) = 'Nedlloyd Wellington, '
             l2 = 21
          elseif(iship.eq.39) then
             shipname(1:15) = 'Seabulk Pride, '
             l2 = 15
          elseif(iship.eq.40) then
             shipname(1:17) = 'Maersk Auckland, '
             l2 = 17
          elseif(iship.eq.41) then
             shipname(1:15) = 'Direct Condor, '
             l2 = 15
          elseif(iship.eq.42) then
             shipname(1:14) = 'USCG Hickory, '
             l2 = 14
          elseif(iship.eq.43) then
             shipname(1:15) = 'Maersk Denton, '
             l2 = 15
          elseif(iship.eq.44) then
             shipname(1:17) = 'Polar Endeavour, '
             l2 = 17
          elseif(iship.eq.45) then
             shipname(1:14) = 'Vega Gotland, '
             l2 = 14
          elseif(iship.eq.46) then
             shipname(1:13) = 'Nora Maersk, '
             l2 = 13
          elseif(iship.eq.47) then
             shipname(1:16) = 'Safmarine Meru, '
             l2 = 16
          elseif(iship.eq.48) then
             shipname(1:14) = 'Horizon Hawk, '
             l2 = 14
          elseif(iship.eq.49) then
             shipname(1:19) = 'CMA CGM Lavender, '
             l2 = 19
          elseif(iship.eq.50) then
             shipname(1:20) = 'E.R. Wilhelmshaven, '
             l2 = 20
          elseif(iship.eq.51) then
             shipname(1:14) = 'R/V Melville, '
             l2 = 14
          elseif(iship.eq.52) then
             shipname(1:18) = 'Josephine Maersk, '
             l2 = 18
          elseif(iship.eq.53) then
             shipname(1:16) = 'Horizon Spirit, '
             l2 = 16
          elseif(iship.eq.54) then
             shipname(1:19) = 'Southern Surveyor, '
             l2 = 19
          elseif(iship.eq.55) then
             shipname(1:11) = 'USCG Spar, '
             l2 = 11
          elseif(iship.eq.56) then
             shipname(1:12) = 'MSC Hobart, '
             l2 = 12
          elseif(iship.eq.57) then
             shipname(1:15) = 'Maersk Phuket, '
             l2 = 15
          elseif(iship.eq.58) then
             shipname(1:13) = 'Maersk Fuji, '
             l2 = 13
          elseif(iship.eq.59) then
             shipname(1:12) = 'Cap Reinga, '
             l2 = 12
          elseif(iship.eq.60) then
             shipname(1:14) = 'JPO Scorpius, '
             l2 = 14
          elseif(iship.eq.61) then
             shipname(1:16) = 'Maersk Fukuoka, '
             l2 = 16
          elseif(iship.eq.62) then
             shipname(1:18) = 'BC San Francisco, '
             l2 = 18
          elseif(iship.eq.63) then
             shipname(1:11) = 'JRS Canis, '
             l2 = 11
          elseif(iship.eq.64) then
             shipname(1:11) = 'Shengking, '
             l2 = 11
          elseif(iship.eq.65) then
             shipname(1:15) = 'Maersk Senang, '
             l2 = 15
          elseif(iship.eq.66) then
             shipname(1:17) = 'MELL Springwood, '
             l2 = 17
          elseif(iship.eq.67) then
             shipname(1:12) = 'MSC Vienna, '
             l2 = 12
          elseif(iship.eq.68) then
             shipname(1:11) = 'MSC Damla, '
             l2 = 11
          elseif(iship.eq.69) then
             shipname(1:19) = 'Safmarine Mulanje, '
             l2 = 19
          else
             write(*,*) 'Invalid number, try again...'	
             go to 1
          endif

10       continue

c endpoints change on some lines...
       if(fnam(1:3).eq.'p08') then
          ship2(1:6) = 'PX08, '
          l1 = 6
          write(*,*)' Choose which track fits this cruise:'
          write(*,*)' 1) Auckland - Panama '
          write(*,*)' 2) Dunedin - Panama '
          read(5,*) iendpoint
       elseif(fnam(1:3).eq.'p06') then
          write(*,*)' Choose which track fits this cruise:'
          write(*,*)' 1) PX06           : Auckland - Suva '
          write(*,*)' 2) PX06 loop A    : Auckland - Noumea '
          write(*,*)' 3) PX06 loop B    : Noumea - Suva     '
          write(*,*)' 4) PX06 loop C    : Suva - Auckland   '
          read(5,*) iendpoint
          if(iendpoint.eq.1) then
             ship2(1:6) = 'PX06, '
             l1 = 6
          elseif(iendpoint.eq.2) then
             ship2(1:13) = 'PX06 Loop A, '
             l1 = 13
          elseif(iendpoint.eq.3) then
             ship2(1:13) = 'PX06 Loop B, '
             l1 = 13
          elseif(iendpoint.eq.4) then
             ship2(1:13) = 'PX06 Loop C, '
             l1 = 13
           endif
       elseif(fnam(1:3).eq.'p09'.or.fnam(1:3).eq.'p13') then
          write(*,*)' Choose which track fits this cruise:'
          write(*,*)' 1) PX06           : Auckland - Suva '
          write(*,*)' 2) PX09           : Auckland - Hawaii '
          write(*,*)' 3) PX06/PX09      : Auckland - Suva - Hawaii '
          write(*,*)
     $      ' 4) PX06/PX09/PX39 : Auckland - Suva - Hawaii - Seattle'
          write(*,*)' 5) PX06/PX31      : Auckland - Suva - Los Angeles'
          write(*,*)
     $      ' 6) PX06/PX12/PX18 : Auckland-Suva-Tahiti-Los Angeles '
          write(*,*)' 7) PX06/PX31      : Tauranga - Suva - Los Angeles'
          write(*,*)' 8) PX13           : Auckland - Los Angeles '
          write(*,*)' 9) PX13           : Auckland - San Francisco '
          write(*,*)'10) PX13           : Tauranga - Los Angeles   '
          read(5,*) iendpoint
          if(iendpoint.eq.1) then
             ship2(1:6) = 'PX06, '
             l1 = 6
          elseif(iendpoint.eq.2) then
             ship2(1:6) = 'PX09, '
             l1 = 6
          elseif(iendpoint.eq.3) then
             ship2(1:11) = 'PX06/PX09, '
             l1 = 11
          elseif(iendpoint.eq.4) then
             ship2(1:16) = 'PX06/PX09/PX39, '
             l1 = 16
          elseif(iendpoint.eq.5) then
             ship2(1:11) = 'PX06/PX31, '
             l1 = 11
          elseif(iendpoint.eq.6) then
             ship2(1:16) = 'PX06/PX12/PX18, '
             l1 = 16
          elseif(iendpoint.eq.7) then
             ship2(1:11) = 'PX06/PX31, '
             l1 = 11
          elseif(iendpoint.eq.8.or.iendpoint.eq.9.or.
     $           iendpoint.eq.10) then
             ship2(1:6) = 'PX13, '
             l1 = 6
          endif
       elseif(fnam(1:3).eq.'p15') then
          write(*,*)' Choose which track fits this cruise:'
          write(*,*)
     $     ' 1) IX21/IX15: Cape of Good Hope - Mauritius - Fremantle'
          write(*,*)' 2) IX02: Cape of Good Hope - Fremantle'
          write(*,*)' 3) IX21/IX15/IX31: Durban-Mauritius-Melbourne'
          write(*,*)' 4) IX21/IX06: Durban-Mauritius-Banda Aceh,Sumatra'
          read(5,*) iendpoint
          if(iendpoint.eq.1) then
             ship2(1:11) = 'IX21/IX15, '
             l1 =11 
          elseif(iendpoint.eq.2) then
             ship2(1:6) = 'IX02, '
             l1 = 6
          elseif(iendpoint.eq.3) then
             ship2(1:16) = 'IX21/IX15/IX31, '
             l1 = 16
          elseif(iendpoint.eq.4) then
             ship2(1:11) = 'IX21/IX06, '
             l1 = 11
          endif
       elseif(fnam(1:3).eq.'i21') then
             ship2(1:11) = 'IX21, '
             l1 =6 
       elseif(fnam(1:3).eq.'p22') then
          write(*,*)' Choose which endpoint fits this cruise:'
          write(*,*)' 1) Palmer Station '
          write(*,*)' 2) Smith Island '
          write(*,*)' 3) King George Island '
          read(5,*) iendpoint
          ship2(1:6) = 'AX22, '
             l1 = 6
       elseif(fnam(1:3).eq.'p28') then
          ship2(1:6) = 'IX28, '
             l1 = 6
       elseif(fnam(1:3).eq.'p31') then
          write(*,*)' Choose which track fits this cruise:'
          write(*,*)' 1) b1  Brisbane - Noumea - Lautoka '
          write(*,*)' 2) b2  Brisbane - Noumea - Suva '
          write(*,*)' 3) b3  Brisbane - Lautoka '
          write(*,*)' 4) b4  Brisbane - Suva '
          read(5,*) iendpoint
          ship2(1:9) = 'PX30/31, '
             l1 = 9
       elseif(fnam(1:3).eq.'p34') then
          ship2(1:6) = 'PX34, '
             l1 = 6
       elseif(fnam(1:3).eq.'p35') then
          ship2(1:6) = 'PX35, '
             l1 = 6
       elseif(fnam(1:3).eq.'p37') then
          write(*,*)' Did this cruise go to: '
          write(*,*)' 1) Hong Kong'
          write(*,*)' 2) Taiwan'
           write(*,*)' 3) P37S: Los Angeles to Honolulu'
          read(5,*) iendpoint
!          ship2(1:16) = 'PX44/PX10/PX37, '
!             l1 = 16
          ship2(1:6) = 'PX37, '
             l1 = 6
       elseif(fnam(1:3).eq.'p38') then
          ship2(1:6) = 'PX38, '
             l1 = 6
       elseif(fnam(1:3).eq.'p40') then
          ship2(1:6) = 'PX40, '
             l1 = 6
       elseif(fnam(1:3).eq.'p50') then
          write(*,*)' Did this cruise go to: '
          write(*,*)' 1) Auckland, NZ    '
          write(*,*)' 2) Lyttelton, NZ'
          read(5,*) istartpoint
          write(*,*)' Did this cruise go to: '
          write(*,*)' 1) Valpariso, Chile'
          write(*,*)' 2) Callao, Peru'
          read(5,*) iendpoint
          ship2(1:6) = 'PX50, '
             l1 = 6
       elseif(fnam(1:3).eq.'p81') then
c 13jan2006 LL - using rdxbtinfo1 here...
          if(iport(1).eq.1) istartpoint = 3
          if(iport(2).eq.1) istartpoint = 4
          if(iport(3).eq.1) istartpoint = 2
          if(iport(4).eq.1) istartpoint = 1
           if(ierr.eq.0) go to 15

          write(*,*)' Did this cruise go to: '
          write(*,*)' 1) Hiroshima, Japan    '
          write(*,*)' 2) Hachinohe, Japan    '
          write(*,*)' 3) Honolulu, Hawaii    '
          write(*,*)' 4) follow px25, stop at 20 deg N'
          read(5,*) istartpoint
15          continue

          if(istartpoint.eq.1.or.istartpoint.eq.2.or.
     $        istartpoint.eq.4) then
             ship2(1:6) = 'PX25, '
          elseif(istartpoint.eq.3) then
             ship2(1:6) = 'PX81, '
          endif
             l1 = 6
       endif
       endif ! typ=tem
c endif for if type = tem
c
       if(fnam(1:3).eq.'p09'.or.fnam(1:3).eq.'p38'.or.
     $     fnam(1:3).eq.'p28'.or.fnam(1:3).eq.'p81'.or.
     $     fnam(1:3).eq.'p22'.or.fnam(1:3).eq.'p06'.or.
     $     fnam(1:3).eq.'p05'.or.fnam(1:3).eq.'p13'.or.
     $     fnam(1:3).eq.'a08'.or.fnam(1:3).eq.'a10') then
! special case p06 - it's lat and lon, b=N-S=lon
           if(fnam(1:3).eq.'p06'.and.fnam(8:8).eq.'b') then
              orient='lon'
           else
             orient = 'lat'
             xmin = -90.0
             xmax = 90.0
           endif
       else
          orient = 'lon'
       endif
        write(33,*)'orient=',orient
       nmaps=1
       nyd=90
!       write(*,*)' opening  ',fnam,' and  ',ofil
       open(7,file=fnam,status='old')
       read(7,*)nsta
!       write(*,*)nsta
       nxd=0
! read .10 file to find begining lat or lon.  Note if orient=lon then putting
! longitude values into xlat,blat,elat (confusing!):
        do 710 i=1,nsta
          read(7,520,end=712)xlat,xlon,idrop
520          format(2f9.3,19x,i3)
          if(i.eq.1) ixbt1 = idrop
          if(orient(1:3).eq.'lon') xlat = xlon
          if(xlat.lt.xmin.or.xlat.gt.xmax)go to 711
          nxd=nxd+1
c latitude
          if(orient(1:3).eq.'lat') then
            if(nxd.eq.1)blat=xlat
            elat=xlat
          else
c longitude
            if(nxd.eq.1)blat=xlon
            elat=xlon
          endif
711       do 710 j=1,8
710       read(7,*)
712     continue
!
        ixbt2 = idrop
        write(33,*) 'blat, elat =', blat, elat
        rewind (7)
! check to see whether section is north-south or south-north
! nssect = -1 means that section is north-south 
! this information will be used also to select the indexing later.
      if (blat .gt. elat) then
        nssect = -1
        nstart=nxd
        xleft = elat
        xright = blat
       write(33,*)nxd,' stations found running from east to west '
       write(33,*)nxd,' North-South  '
      else
        nssect = 1
       nstart=1
        xleft = blat
        xright = elat
       write(33,*)nxd,' stations found running from west to east '
       write(33,*)nxd,' South-North  '
      endif
      write(33,*)'before scaling:'
        write(33,*)xright,'= xright, xleft =',xleft
! compute scaling
        if(xleft.lt.0.)xleft=.1*ifix((xleft+.05)*10.)-.05
        if(xright.gt.0.)xright=.1*ifix((xright-.05)*10.)+.05
        if(xleft.gt.0.)xleft=.1*ifix((xleft+.15)*10.)-.05
        if(xright.lt.0.)xright=.1*ifix((xright-.15)*10.)+.05
        dtot=xright-xleft
! deltax set to .1 in data statement
        delx=deltax
      write(33,*)'after scaling:'
        write(33,*)xright,'= xright, xleft =',xleft
        write(33,*)' delx=',delx,' dtot=',dtot
        nxg=nint((xright-xleft)/delx)+1
        nyg=nint((ybot-ytop)/dely)+1
        write(33,*)' nxg,nyg=',nxg,nyg
! read data
        ns=nstart-nssect
       if(iw.eq.1) write(33,*) 'ns=',ns
       read(7,*)nsta
       do 720 i=1,nsta
       read(7,*,end=721)xlat,xlon
       if(iw.eq.1) write(33,*)xlat,xlon
       if(orient(1:3).eq.'lat') then
           if(xlat.lt.xmin.or.xlat.gt.xmax)then
          read(7,'(12f6.3)')(xtmp(j),j=1,nyd)
          go to 720
          endif
          ns=ns+nssect
          dis(ns)=xlat
          dis1(ns)=xlon
       else
           if(xlon.lt.xmin.or.xlon.gt.xmax)then
          write(33,*) 'lon.lt.min.or.gt.max', xlon
          read(7,'(12f6.3)')(xtmp(j),j=1,nyd)
          go to 720
          endif
          ns=ns+nssect
          dis(ns)=xlon
          dis1(ns)=xlat
       endif
! why are we reading this into 2, nyd (nyd=90) it appears we
! are skipping the last value and duplicating the first in j=1
! probably ok since we're reading the 10m average file:
       read(7,'(12f6.3)')(sdata(j,ns,1),j=2,nyd)
       sdata(1,ns,1)=sdata(2,ns,1)
720       continue
721       continue
       close(7)
! dely set to 10.0 in data statement
       do 730 i=1,nyd
730       dep(i)=dely*(float(i)-1.5)
c now replace tem with delta if typ.eq.del
       if(typ.ne.'del'.and.typ.ne.'sal')go to 731
! Check if user wants to use the argo corrected salinity or not:
        write(*,*)
789     write(*,*)'Which .10 salinity should I use? '
        write(*,*)'1) .10s - historical ts => .sal'
        write(*,*)'2) .10c - Argo corrected historical ts => .sac'
        write(*,*)'          (run add_10s_10a.x first!)  '
        write(*,*)'3) .10d - p28 ds file'
        write(*,*)'4) .10s_argo - Argo only => .ssa'
        write(*,*)'5) .10c_argo - Argo + argo&xctd correction => .ssc'
        write(*,*)'Enter number: '

        read(5,*) its
        if(its.eq.1) then
           fnam(12:12)='s'
        elseif(its.eq.2) then
           fnam(12:12)='c'
           if(typ.ne.'tem') ofil(11:12) = 'ac'
        elseif(its.eq.3) then
           fnam(12:12)='d'
           if(typ.ne.'tem') ofil(12:12) = 'd'
        elseif(its.eq.4) then
           fargo(12:17)='s_argo'
           if(typ.ne.'tem') ofil(11:12) = 'sa'
        elseif(its.eq.5) then
           fargo(12:17)='c_argo'
           if(typ.ne.'tem') ofil(11:12) = 'sc'
        else
           go to 789
        endif
!        fnam/'p099105a.10 '/
!        ofil/'p099105a.tem'/
!       fargo/'p371110a.10s_argo'/
!              12345678901234567

! open appropriate .10s/.10s_argo/.10X file:
        if(its.le.3) then
           open(7,file=fnam,status='old')
           write(33,*)' opening ',fnam
        elseif(its.ge.4) then
           open(7,file=fargo,status='old')
           write(33,*)' opening ',fargo
        endif
        ns=nstart-nssect
        read(7,*)nsta
        do 740 i=1,nsta
        read(7,*,end=741)xlat,xlon
!       xlon=-1.*xlon
!       write(*,*)xlat,xlon
       if(orient(1:3).eq.'lat') then
          if(xlat.lt.xmin.or.xlat.gt.xmax)then
          read(7,'(12f6.3)')(xtmp(j),j=1,nyd)
          go to 740
          endif
          ns=ns+nssect
          if(xlat.ne.dis(ns))then
          write(*,*)' oh-oh, wrong salinity station, job bombs  '
          stop
          endif
       else
          if(xlon.lt.xmin.or.xlon.gt.xmax)then
          read(7,'(12f6.3)')(xtmp(j),j=1,nyd)
          go to 740
          endif
          ns=ns+nssect
          if(xlon.ne.dis(ns))then
          write(*,*)' oh-oh, wrong salinity station, job bombs  '
          stop
          endif
       endif
       if(typ.eq.'sal') then
          read(7,'(12f6.3)')(xtmp(j),j=1,nyd)
          jstart = 1
       else
          read(7,'(12f6.3)')(xtmp(j),j=2,nyd)
          xtmp(1)=xtmp(2)
          jstart = 2
       endif

       do 745 j=jstart,nyd

c missing value = -9.999 for p22 (a22)
c missing value = -0.999 for the rest  (what about p28?)
        if(fnam(2:3).eq.'22') then
           if(xtmp(j).eq.-9.999)then
              sdata(j,ns,1)=-9.999
              go to 745
           endif
        else
           if(xtmp(j).eq.-.999)then
              sdata(j,ns,1)=-.999
              go to 745
! try this for atlantic 19jun2013LL
           elseif(xtmp(j).eq.-99.999)then
              sdata(j,ns,1)=-.999
              go to 745
           endif
        endif

!        if(j.eq.2)write(*,*)ns,dep(j),sdata(j,ns,1),xtmp(j)

        if(typ.eq.'sal') go to 744
        sv350=v350p(dep(j))
         spv=eos80(dep(j),sdata(j,ns,1),xtmp(j))
         sdata(j,ns,1)=1.e5*(spv-sv350)

744        continue
        if(typ.ne.'sal') go to 745
        sdata(j,ns,1) = xtmp(j)
745       continue

       if(typ.eq.'sal') go to 740
       sdata(1,ns,1)=sdata(2,ns,1)
740       continue
741       continue
!       write(*,*)' top row of delta data:'
!       write(*,*)(sdata(1,j,1),j=1,nxd)
       close(7)
c
731       continue
        open(17,file=ofil)
        write(17,'(2i8,2f8.2,2f8.0)')nxg,nyg,xleft,xright,ybot,ytop        
        do 310 jg=1,nyg   
        yg=ytop+dely*(jg-1)        
!        write(*,*)yg,ny      
        xt=-1.e38
        not=1    
!
        open(42,file='trkpos.txt',status='unknown',form='formatted')
        write(42,*) nxg
        do 300 ig=1,nxg   
        xg=xleft+delx*(ig-1)       
        if(iw.eq.1) write(33,*)'ns=', nsta
        if(iw.eq.1) write(33,*)'dis', (dis(kk),kk=1,nsta)
        if(iw.eq.1) write(33,*)'dis1',(dis1(kk),kk=1,nsta)
! 17dec2010 call createpos for p05 too?
! 10jan2011 LL does this work for all?  Test on p28 with 'lat'
!        if(fnam(1:3).eq.'p31'.or.fnam(1:3).eq.'p05') then
           call createpos(xg,dis,dis1,nsta,orient,trkpos)
!        endif
        if(orient.eq.'lon') then
           write(42,'(f8.4,1x,f8.4)') trkpos , xg
        elseif(orient.eq.'lat') then
           write(42,'(f8.4,1x,f8.4)') xg, trkpos
        endif
        if(iw.eq.1) write(33,*)'xt=',xt,' ig=',ig
        if(xg.lt.xt)go to 51       
        if(ig.gt.1)go to 52        
        call firstx(npts,xleft,fnam)    
        ygpos=ypo(yg,y)   
        go to 53 
52      call bshift(npts,not,fnam)      
53      if(npts.lt.36)go to 32     
        if(not.eq.1)call covar(as3,w4,evar,efold2,yscale,npts,tbar)    
        nyet=1   
        go to 51 
32      if(not.eq.1)call covar(asi,w4,evar,efold2,yscale,npts,tbar)    
!       grid est = c * a inverse * data     
51       continue
        if(iw.eq.1) write(33,*) 'bef xpo,xg', xg
        if(iw.eq.1) write(33,*) 'bef xpo,x', (x(1,kk),kk=1,6)
        xgpos=xpo(xg,x)   
        do 50 i=1,npts    
        diss=(xgpos-xpos(i))**2+((ygpos-ypos(i))*yscale)**2   
50      c2(i)=exp(-sqrt(diss/efold2))       
        do 299 jm=1,nmaps 
299     grid(ig,jm)=tbar(jm)+sdot(npts,w4(1,jm),1,c2,1)       
300     continue 
        close(42)
!
        do 130 jm=1,nmaps
! 23jan2013 LL get rid of pesky nan's...
!         if(isnan(grid(1,1))) then
          if(grid(1,1).ne.grid(1,1)) then
            do 245 kr = 1, nxg
               grid(kr,1) = -99.999
245         continue
          endif
!       if(jg.eq.1)then
!       if(typ.eq.'tem'.or.typ.eq.'sal')write(*,'(11f7.3)')
!     $                             (grid(ind,jm),ind=1,nxg)
!       if(typ.eq.'del')write(*,'(11f7.2)')(grid(ind,jm),ind=1,nxg)
!       endif
       if(typ.eq.'tem'.or.typ.eq.'sal')write(17,'(11f7.3)')
     $                             (grid(ind,jm),ind=1,nxg)
       if(typ.eq.'del')write(17,'(11f7.2)')(grid(ind,jm),ind=1,nxg)
130       continue
310     continue
c ferret
       if(typ(1:3).eq.'tem') then
!          write(*,*) 'cal fertem',fnam,typ,nyg,nxg,xleft,xright,ixbt1,ixbt2
          call fertem(fnam,typ,nyg,nxg,xleft,xright,ixbt1,ixbt2,
     $                 shipname,iendpoint,istartpoint,ship2,orient,
     $                 l1,l2,nsta)
       endif
          stop
        end
c  ************************************************
        subroutine firstx(npts,xleft,fnam)       
        common data(90,600,1),dis(600),dep(105),x(6,6),y(6,6),z(6,6,1),
     *z1(36,1),xpos(36),ypos(36)
       common /count/nx,ny,xt,xg,yg,nyd,nxd,nyg,nxg,nvar,nyet,nmaps
       character*12 fnam
        ny=4     
        do 20 i=4,nyd
       if(yg.lt.dep(ny))go to 21
20      ny=ny+1  
21      ny=min(ny,nyd-2)  
        nx=4     
        do 25 i=4,nxd
c missing value
        if(fnam(2:3).eq.'22') then
        if(data(ny-3,nx-3,1).ne.-9.999.and.dis(nx-1).ge.xleft)go to 26
        else
        if(data(ny-3,nx-3,1).ne.-.999.and.dis(nx-1).ge.xleft)go to 26
        endif

25      nx=nx+1  
26       nx=min(nx,nxd-2)
        xt=dis(nx)        
        npts=0   
        do 10 i=1,6       
        do 10 j=1,6       
        x(i,j)=dis(nx+j-4)
        y(i,j)=dep(ny+i-4)
        do 11 jm=1,nmaps  
11      z(i,j,jm)=data(ny+i-4,nx+j-4,jm)    
c missing value
       if(fnam(2:3).eq.'22') then
           if(z(i,j,1).eq.-9.999)go to 10       
       else
           if(z(i,j,1).eq.-.999)go to 10       
       endif

        npts=npts+1       
        do 12 jm=1,nmaps  
12      z1(npts,jm)=z(i,j,jm)      
        xpos(npts)=j      
        ypos(npts)=i      
10      continue 
        return   
        end      
c  *******************************************
        subroutine bshift(npts,not,fnam)
        common data(90,600,1),dis(600),dep(105),x(6,6),y(6,6),z(6,6,1),
     *z1(36,1),xpos(36),ypos(36)
       common /count/nx,ny,xt,xg,yg,nyd,nxd,nyg,nxg,nvar,nyet,nmaps
       character*12 fnam
        not=1    
        nx=nx+1  
        xt=dis(nx)        
        if(nx.ge.nxd-1)go to 1     
c missing value
       if(fnam(2:3).eq.'22') then
           if(data(ny-3,nx+2,1).eq.-9.999)go to 1        
       else
           if(data(ny-3,nx+2,1).eq.-.999)go to 1        
       endif

        do 20 i=1,6       
        do 20 j=1,6       
        x(i,j)=dis(nx-4+j)
        y(i,j)=dep(ny-4+i)
        do 20 jm=1,nmaps  
20      z(i,j,jm)=data(ny+i-4,nx+j-4,jm)    
        npts=0   
        do 10 i=1,6       
        do 10 j=1,6       
c missing value
       if(fnam(2:3).eq.'22') then
           if(z(i,j,1).eq.-9.999)go to 10       
       else
           if(z(i,j,1).eq.-.999)go to 10       
       endif
        npts=npts+1       
        do 11 jm=1,nmaps  
11      z1(npts,jm)=z(i,j,jm)      
        xpos(npts)=j      
        ypos(npts)=i      
10      continue 
        return   
1       not=0    
        return   
        end      
!------------------------------------------------------------------
        function xpo(xg,x)
        dimension x(6,6)  
        i=1      
        do 10 j=2,5       
10      if(xg.ge.x(1,j))i=i+1      
        if((x(1,i+1)-x(1,i)).eq.0.0) then
          print *, x(1,i+1), x(1,i), i
           write(33,*) 'Dup pos ', x(1,i+1), x(1,i), i
          stop 'Possible duplicate position! help!'
       endif
        xpo=float(i)+(xg-x(1,i))/(x(1,i+1)-x(1,i))   
        return   
        end      
        function ypo(yg,y)
        dimension y(6,6)  
        i=1      
        do 10 j=2,5       
10      if(yg.ge.y(j,1))i=i+1      
        if((y(i+1,1)-y(i,1)).eq.0.0) stop 'two'
        ypo=float(i)+(yg-y(i,1))/(y(i+1,1)-y(i,1))   
        return   
        end      
c  *************************************************
        subroutine covar(as,w2,evar,efold2,yscale,npts,tbar) 
!        dimension kpvt(150),wk(150),det(2),inert(3)
        dimension kpvt(150),wk(666),det(2),inert(3)
        dimension w2(36,1),res(36,1),as(666),tbar(1)   
        common data(90,600,1),dis(600),dep(105),x(6,6),y(6,6),z(6,6,1),
     *z1(36,1),xpos(36),ypos(36)
       common /count/nx,ny,xt,xg,yg,nyd,nxd,nyg,nxg,nvar,nyet,nmaps
        if(npts.eq.36.and.nyet.eq.1)go to 2 
        do 10 i=1,npts    
        do 11 j=1,i       
        k=(i*(i-1)/2)+j   
        dist=(xpos(j)-xpos(i))**2+((ypos(j)-ypos(i))*yscale)**2        
11      as(k)=exp(-sqrt(dist/efold2))       
10      as(k)=as(k)+evar  
c invert covariance matrices       
c        write(*,*)npts       
c
c       write(*,*)'call to sspdi: npts = ',npts
       call sspfa(as,npts,kpvt,info)
c       write(*,*)' info=',info
       job=111
       call sspdi(as,npts,kpvt,det,inert,wk,job)
c       write(*,*)' det=',det(1)*10.**det(2)
c       write(*,*)'inert=',inert(1),inert(2),inert(3)
c
2       do 33 j=1,nmaps   
        tbar(j)=0.        
        do 31 i=1,npts    
31      tbar(j)=tbar(j)+z1(i,j)    
        tbar(j)=tbar(j)/float(npts)
        do 32 i=1,npts    
32      res(i,j)=z1(i,j)-tbar(j)   
33      call vmulsf(as,npts,npts,res(1,j),1,npts,w2(1,j),npts)    
        return   
        end      
c
c matrix multiplication, symmetric x full
c
       subroutine vmulsf(a,l,m,b,n,ib,c,ic)
       dimension a(*),b(ib,n),c(ic,n)
       do 10 i=1,l
       do 10 j=1,n
       c(i,j)=0.
       do 10 k=1,m
       ind=(i*(i-1)/2)+k
       if(k.gt.i)ind=(k*(k-1)/2)+i
10       c(i,j)=c(i,j)+a(ind)*b(k,j)
       return
       end
!
      subroutine sspdi(ap,n,kpvt,det,inert,work,job)
      integer n,job
!      real ap(1),work(1)
      real ap(*),work(*)
      real det(2)
!      integer kpvt(1),inert(3)
      integer kpvt(*),inert(3)
      real akkp1,sdot,temp
      real ten,d,t,ak,akp1
      integer ij,ik,ikp1,iks,j,jb,jk,jkp1
      integer k,kk,kkp1,km1,ks,ksj,kskp1,kstep
      logical noinv,nodet,noert
      noinv = mod(job,10) .eq. 0
      nodet = mod(job,100)/10 .eq. 0
      noert = mod(job,1000)/100 .eq. 0
      if (nodet .and. noert) go to 140
         if (noert) go to 10
            inert(1) = 0
            inert(2) = 0
            inert(3) = 0
   10    continue
         if (nodet) go to 20
            det(1) = 1.0e0
            det(2) = 0.0e0
            ten = 10.0e0
   20    continue
         t = 0.0e0
         ik = 0
         do 130 k = 1, n
            kk = ik + k
            d = ap(kk)
            if (kpvt(k) .gt. 0) go to 50
               if (t .ne. 0.0e0) go to 30
                  ikp1 = ik + k
                  kkp1 = ikp1 + k
                  t = abs(ap(kkp1))
                  d = (d/t)*ap(kkp1+1) - t
               go to 40
   30          continue
                  d = t
                  t = 0.0e0
   40          continue
   50       continue
            if (noert) go to 60
               if (d .gt. 0.0e0) inert(1) = inert(1) + 1
               if (d .lt. 0.0e0) inert(2) = inert(2) + 1
               if (d .eq. 0.0e0) inert(3) = inert(3) + 1
   60       continue
            if (nodet) go to 120
               det(1) = d*det(1)
               if (det(1) .eq. 0.0e0) go to 110
   70             if (abs(det(1)) .ge. 1.0e0) go to 80
                     det(1) = ten*det(1)
                     det(2) = det(2) - 1.0e0
                  go to 70
   80             continue
   90             if (abs(det(1)) .lt. ten) go to 100
                     det(1) = det(1)/ten
                     det(2) = det(2) + 1.0e0
                  go to 90
  100             continue
  110          continue
  120       continue
            ik = ik + k
  130    continue
  140 continue
      if (noinv) go to 270
         k = 1
         ik = 0
  150    if (k .gt. n) go to 260
            km1 = k - 1
            kk = ik + k
            ikp1 = ik + k
            kkp1 = ikp1 + k
            if (kpvt(k) .lt. 0) go to 180
              if(ap(kk).eq.0.0) stop 'three'
               ap(kk) = 1.0e0/ap(kk)
               if (km1 .lt. 1) go to 170
                  call scopy(km1,ap(ik+1),1,work,1)
                  ij = 0
                  do 160 j = 1, km1
                     jk = ik + j
                     ap(jk) = sdot(j,ap(ij+1),1,work,1)
                     call saxpy(j-1,work(j),ap(ij+1),1,ap(ik+1),1)
                     ij = ij + j
  160             continue
                  ap(kk) = ap(kk) + sdot(km1,work,1,ap(ik+1),1)
  170          continue
               kstep = 1
            go to 220
  180       continue
               t = abs(ap(kkp1))
              if(t.eq.0.0) stop 'four'
               ak = ap(kk)/t
               akp1 = ap(kkp1+1)/t
               akkp1 = ap(kkp1)/t
               d = t*(ak*akp1 - 1.0e0)
              if(d.eq.0.0) stop 'five'
               ap(kk) = akp1/d
               ap(kkp1+1) = ak/d
               ap(kkp1) = -akkp1/d
               if (km1 .lt. 1) go to 210
                  call scopy(km1,ap(ikp1+1),1,work,1)
                  ij = 0
                  do 190 j = 1, km1
                     jkp1 = ikp1 + j
                     ap(jkp1) = sdot(j,ap(ij+1),1,work,1)
                     call saxpy(j-1,work(j),ap(ij+1),1,ap(ikp1+1),1)
                     ij = ij + j
  190             continue
                  ap(kkp1+1) = ap(kkp1+1)
     1                         + sdot(km1,work,1,ap(ikp1+1),1)
                  ap(kkp1) = ap(kkp1)
     1                       + sdot(km1,ap(ik+1),1,ap(ikp1+1),1)
                  call scopy(km1,ap(ik+1),1,work,1)
                  ij = 0
                  do 200 j = 1, km1
                     jk = ik + j
                     ap(jk) = sdot(j,ap(ij+1),1,work,1)
                     call saxpy(j-1,work(j),ap(ij+1),1,ap(ik+1),1)
                     ij = ij + j
  200             continue
                  ap(kk) = ap(kk) + sdot(km1,work,1,ap(ik+1),1)
  210          continue
               kstep = 2
  220       continue
            ks = iabs(kpvt(k))
            if (ks .eq. k) go to 250
               iks = (ks*(ks - 1))/2
               call sswap(ks,ap(iks+1),1,ap(ik+1),1)
               ksj = ik + ks
               do 230 jb = ks, k
                  j = k + ks - jb
                  jk = ik + j
                  temp = ap(jk)
                  ap(jk) = ap(ksj)
                  ap(ksj) = temp
                  ksj = ksj - (j - 1)
  230          continue
               if (kstep .eq. 1) go to 240
                  kskp1 = ikp1 + ks
                  temp = ap(kskp1)
                  ap(kskp1) = ap(kkp1)
                  ap(kkp1) = temp
  240          continue
  250       continue
            ik = ik + k
            if (kstep .eq. 2) ik = ik + k + 1
            k = k + kstep
         go to 150
  260    continue
  270 continue
      return
      end
!  ****************************************
      subroutine sspfa(ap,n,kpvt,info)
!      integer n,kpvt(1),info
      integer n,kpvt(*),info
!      real ap(1)
      real ap(*)
      real ak,akm1,bk,bkm1,denom,mulk,mulkm1,t
      real absakk,alpha,colmax,rowmax
      integer isamax,ij,ijj,ik,ikm1,im,imax,imaxp1,imim,imj,imk
      integer j,jj,jk,jkm1,jmax,jmim,k,kk,km1,km1k,km1km1,km2,kstep
      logical swap
      alpha = (1.0e0 + sqrt(17.0e0))/8.0e0
      info = 0
      k = n
      ik = (n*(n - 1))/2
   10 continue
         if (k .eq. 0) go to 200
         if (k .gt. 1) go to 20
            kpvt(1) = 1
            if (ap(1) .eq. 0.0e0) info = 1
            go to 200
   20    continue
         km1 = k - 1
         kk = ik + k
         absakk = abs(ap(kk))
         imax = isamax(k-1,ap(ik+1),1)
         imk = ik + imax
         colmax = abs(ap(imk))
         if (absakk .lt. alpha*colmax) go to 30
            kstep = 1
            swap = .false.
         go to 90
   30    continue
            rowmax = 0.0e0
            imaxp1 = imax + 1
            im = imax*(imax - 1)/2
            imj = im + 2*imax
            do 40 j = imaxp1, k
               rowmax = amax1(rowmax,abs(ap(imj)))
               imj = imj + j
   40       continue
            if (imax .eq. 1) go to 50
               jmax = isamax(imax-1,ap(im+1),1)
               jmim = jmax + im
               rowmax = amax1(rowmax,abs(ap(jmim)))
   50       continue
            imim = imax + im
            if (abs(ap(imim)) .lt. alpha*rowmax) go to 60
               kstep = 1
               swap = .true.
            go to 80
   60       continue
           if(rowmax.eq.0.0) stop 'six'
            if (absakk .lt. alpha*colmax*(colmax/rowmax)) go to 70
               kstep = 1
               swap = .false.
            go to 80
   70       continue
               kstep = 2
               swap = imax .ne. km1
   80       continue
   90    continue
         if (amax1(absakk,colmax) .ne. 0.0e0) go to 100
            kpvt(k) = k
            info = k
         go to 190
  100    continue
         if (kstep .eq. 2) go to 140
            if (.not.swap) go to 120
               call sswap(imax,ap(im+1),1,ap(ik+1),1)
               imj = ik + imax
               do 110 jj = imax, k
                  j = k + imax - jj
                  jk = ik + j
                  t = ap(jk)
                  ap(jk) = ap(imj)
                  ap(imj) = t
                  imj = imj - (j - 1)
  110          continue
  120       continue
            ij = ik - (k - 1)
            do 130 jj = 1, km1
               j = k - jj
               jk = ik + j
              if(ap(kk).eq.0.0) stop 'seven'
               mulk = -ap(jk)/ap(kk)
               t = mulk
               call saxpy(j,t,ap(ik+1),1,ap(ij+1),1)
               ijj = ij + j
               ap(jk) = mulk
               ij = ij - (j - 1)
  130       continue
            kpvt(k) = k
            if (swap) kpvt(k) = imax
         go to 190
  140    continue
            km1k = ik + k - 1
            ikm1 = ik - (k - 1)
            if (.not.swap) go to 160
               call sswap(imax,ap(im+1),1,ap(ikm1+1),1)
               imj = ikm1 + imax
               do 150 jj = imax, km1
                  j = km1 + imax - jj
                  jkm1 = ikm1 + j
                  t = ap(jkm1)
                  ap(jkm1) = ap(imj)
                  ap(imj) = t
                  imj = imj - (j - 1)
  150          continue
               t = ap(km1k)
               ap(km1k) = ap(imk)
               ap(imk) = t
  160       continue
            km2 = k - 2
            if (km2 .eq. 0) go to 180
               ak = ap(kk)/ap(km1k)
               km1km1 = ikm1 + k - 1
              if(ap(km1k).eq.0.0) stop 'eight'
               akm1 = ap(km1km1)/ap(km1k)
               denom = 1.0e0 - ak*akm1
               ij = ik - (k - 1) - (k - 2)
               do 170 jj = 1, km2
                  j = km1 - jj
                  jk = ik + j
                  bk = ap(jk)/ap(km1k)
                  jkm1 = ikm1 + j
                  bkm1 = ap(jkm1)/ap(km1k)
                 if(denom.eq.0.0) stop 'nine'
                  mulk = (akm1*bk - bkm1)/denom
                  mulkm1 = (ak*bkm1 - bk)/denom
                  t = mulk
                  call saxpy(j,t,ap(ik+1),1,ap(ij+1),1)
                  t = mulkm1
                  call saxpy(j,t,ap(ikm1+1),1,ap(ij+1),1)
                  ap(jk) = mulk
                  ap(jkm1) = mulkm1
                  ijj = ij + j
                  ij = ij - (j - 1)
  170          continue
  180       continue
            kpvt(k) = 1 - k
            if (swap) kpvt(k) = -imax
            kpvt(k-1) = kpvt(k)
  190    continue
         ik = ik - (k - 1)
         if (kstep .eq. 2) ik = ik - (k - 2)
         k = k - kstep
      go to 10
  200 continue
      return
      end
!  *******************************************
      subroutine saxpy(n,sa,sx,incx,sy,incy)
!      real sx(1),sy(1),sa
      real sx(*),sy(*),sa
      if(n.le.0.or.sa.eq.0.e0) return
      if(incx.eq.incy) if(incx-1) 5,20,60
    5 continue
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        sy(iy) = sy(iy) + sa*sx(ix)
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
   20 m = mod(n,4)
      if( m .eq. 0 ) go to 40
      do 30 i = 1,m
        sy(i) = sy(i) + sa*sx(i)
   30 continue
      if( n .lt. 4 ) return
   40 mp1 = m + 1
      do 50 i = mp1,n,4
        sy(i) = sy(i) + sa*sx(i)
        sy(i + 1) = sy(i + 1) + sa*sx(i + 1)
        sy(i + 2) = sy(i + 2) + sa*sx(i + 2)
        sy(i + 3) = sy(i + 3) + sa*sx(i + 3)
   50 continue
      return
   60 continue
      ns = n*incx
          do 70 i=1,ns,incx
          sy(i) = sa*sx(i) + sy(i)
   70     continue
      return
      end
      real function sdot(n,sx,incx,sy,incy)
c      real sx(1),sy(1)
!20mar2019 test:      real sx(666),sy(666)
      real sx(*),sy(*)
      sdot = 0.0e0
      if(n.le.0)return
      if(incx.eq.incy) if(incx-1)5,20,60
    5 continue
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        sdot = sdot + sx(ix)*sy(iy)
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
   20 m = mod(n,5)
      if( m .eq. 0 ) go to 40
      do 30 i = 1,m
        sdot = sdot + sx(i)*sy(i)
   30 continue
      if( n .lt. 5 ) return
   40 mp1 = m + 1
      do 50 i = mp1,n,5
        sdot = sdot + sx(i)*sy(i) + sx(i + 1)*sy(i + 1) +
     1   sx(i + 2)*sy(i + 2) + sx(i + 3)*sy(i + 3) + sx(i + 4)*sy(i + 4)
   50 continue
      return
   60 continue
      ns=n*incx
      do 70 i=1,ns,incx
        sdot = sdot + sx(i)*sy(i)
   70   continue
      return
      end
!
      subroutine scopy(n,sx,incx,sy,incy)
!      real sx(1),sy(1)
      real sx(*),sy(*)
      if(n.le.0)return
      if(incx.eq.incy) if(incx-1) 5,20,60
    5 continue
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        sy(iy) = sx(ix)
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
   20 m = mod(n,7)
      if( m .eq. 0 ) go to 40
      do 30 i = 1,m
        sy(i) = sx(i)
   30 continue
      if( n .lt. 7 ) return
   40 mp1 = m + 1
      do 50 i = mp1,n,7
        sy(i) = sx(i)
        sy(i + 1) = sx(i + 1)
        sy(i + 2) = sx(i + 2)
        sy(i + 3) = sx(i + 3)
        sy(i + 4) = sx(i + 4)
        sy(i + 5) = sx(i + 5)
        sy(i + 6) = sx(i + 6)
   50 continue
      return
   60 continue
      ns = n*incx
          do 70 i=1,ns,incx
          sy(i) = sx(i)
   70     continue
      return
      end
!
      subroutine sswap(n,sx,incx,sy,incy)
!      real sx(1),sy(1),stemp1,stemp2,stemp3
      real sx(*),sy(*),stemp1,stemp2,stemp3
      if(n.le.0)return
      if(incx.eq.incy) if(incx-1) 5,20,60
    5 continue
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        stemp1 = sx(ix)
        sx(ix) = sy(iy)
        sy(iy) = stemp1
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
   20 m = mod(n,3)
      if( m .eq. 0 ) go to 40
      do 30 i = 1,m
        stemp1 = sx(i)
        sx(i) = sy(i)
        sy(i) = stemp1
   30 continue
      if( n .lt. 3 ) return
   40 mp1 = m + 1
      do 50 i = mp1,n,3
        stemp1 = sx(i)
        stemp2 = sx(i+1)
        stemp3 = sx(i+2)
        sx(i) = sy(i)
        sx(i+1) = sy(i+1)
        sx(i+2) = sy(i+2)
        sy(i) = stemp1
        sy(i+1) = stemp2
        sy(i+2) = stemp3
   50 continue
      return
   60 continue
      ns = n*incx
        do 70 i=1,ns,incx
        stemp1 = sx(i)
        sx(i) = sy(i)
        sy(i) = stemp1
   70   continue
      return
      end
      integer function isamax(n,sx,incx)
c      real sx(1),smax,xmag
      real sx(666),smax,xmag
      isamax = 0
      if(n.le.0) return
      isamax = 1
      if(n.le.1)return
      if(incx.eq.1)goto 20
      smax = abs(sx(1))
      ns = n*incx
      ii = 1
          do 10 i=1,ns,incx
          xmag = abs(sx(i))
          if(xmag.le.smax) go to 5
          isamax = ii
          smax = xmag
    5     ii = ii + 1
   10     continue
      return
   20 smax = abs(sx(1))
      do 30 i = 2,n
         xmag = abs(sx(i))
         if(xmag.le.smax) go to 30
         isamax = i
         smax = xmag
   30 continue
      return
      end
c equation of state for seawater eos80      
c *****************************************************************************
      real function eos80(p1,t,s)  
c *****************************************************************************
c equation of state for seawater proposed by jpots 1980       
c references     
c millero et al 1980, deep-sea res.,27a,255-264      
c jpots ninth report 1978,tenth report 1980 
c units:
c       pressure        p        bars       
c       input pressure  p1       decibars   
c       temperature     t        deg celsius (ipts-68)        
c       salinity        s        nsu (ipss-78)       
c       densityrho      kg/m**3    
c       spec. vol.      eos80    m**3/kg    
c check value: eos80 = 9.435561e-4 m**3/kg for s = 40 nsu,    
c t = 40 deg c, p = 1000 bars.     
c       
c n fofonoff revised oct 7 1980    
c modified to take db input pressure, and output in cm**3/gm 28nov80   
c n.bray
      real p1,p,t,s,rho,sr,r1,r2,r3,r4      
      real a,b,c,d,e,a1,b1,aw,bw,k,k0,kw    
c equiv 
      equivalence (e,d,b1,r4),(bw,b,r3),(c,a1,r2)    
      equivalence (aw,a,r1,r0),(kw,k0,k)    
c convert pressure to bars and square root salinity. 
      p = p1*.1  
      sr = sqrt(abs(s))   
c compute density pure water at atm pressure
      r1 = ((((6.536332e-9*t-1.120083e-6)*t+1.001685e-4)*t    
     x-9.095290e-3)*t+6.793952e-2)*t+999.842594      
c seawater density atm press.      
      r2 = (((5.3875e-9*t-8.2467e-7)*t+7.6438e-5)*t-4.0899e-3)*t       
     x+8.24493e-1
      r3 = (-1.6546e-6*t+1.0227e-4)*t-5.72466e-3     
      r4 = 4.8314e-4      
      rho = (r4*s + r3*sr + r2)*s + r1      
c specific volume at atmospheric pressure   
      eos80 = 1.e+3/rho   
      if(p.eq.0.0)return  
c compute compression terms        
      e = (9.1697e-10*t+2.0816e-8)*t-9.9348e-7       
      bw = (5.2787e-8*t-6.12293e-6)*t+8.50935e-5     
      b = bw + e*s        
c       
      d = 1.91075e-4      
      c = (-1.6078e-6*t-1.0981e-5)*t+2.2838e-3       
      aw = ((-5.77905e-7*t+1.16092e-4)*t+1.43713e-3)*t        
     x+3.239908  
      a = (d*sr + c)*s + aw        
c       
      b1 = (-5.3009e-4*t+1.6483e-2)*t+7.944e-2       
      a1 = ((-6.1670e-5*t+1.09987e-2)*t-0.603459)*t+54.6746   
      kw = (((-5.155288e-5*t+1.360477e-2)*t-2.327105)*t       
     x+148.4206)*t+19652.21        
      k0 = (b1*sr + a1)*s + kw     
c       
      k = (b*p + a)*p + k0
       if(k.eq.0) stop 'ten'
      eos80=eos80*(1.0 - p/k)      
      return     
      end        
! *****************************************************************************
! v350p fcn ***** oct 7 1980 ***** 
      real function v350p(p1)      
! ******************************** 
! specific volume (cm**3/gm) for s = 35 nsu (ipss-78),        
! temperature 0 deg celsius (ipts-68) and pressure in decibars.        
! equation derived from eos80      
! check value: v350p = 9.337431e-4 m**3/kg for p = 1000 bars. 
! modified to accept input pressure in db and output sp.vol in
! cm**3/gm 28 nov 80.  n bray.     
      p = p1*.1  
      alpha = 9.72662e-4*(1.0-p/(21582.27+(3.35941+5.032e-5*p)*p))     
      alpha = 1.e+3*alpha 
      v350p = alpha       
      return     
      end        
!*****************************************************************

       subroutine makedate(idy1,idy2,imo1,imo2,iyr1,iyr2,adate)
! writes a character string of cruise dates
       character*23 adate
       adate = '00 Jan 2000-00 Jan 2000'
!                1234567890123456789012345
!       print *,'in makedate:',idy1,' ',idy2,' ',imo1,' ',imo2,' ',iyr1,' ',iyr2
       if(iyr1.le.99.and.iyr1.ge.86) then
! we're in the 1900's
          adate(8:9) = '19'
          adate(20:21) = '19'
       endif
        write(adate(1:2),'(i2)') idy1
        if(imo1.eq.1) then
           write(adate(4:6),'(a3)') 'Jan'
        elseif(imo1.eq.2) then
           write(adate(4:6),'(a3)') 'Feb'
        elseif(imo1.eq.3) then
           write(adate(4:6),'(a3)') 'Mar'
        elseif(imo1.eq.4) then
           write(adate(4:6),'(a3)') 'Apr'
        elseif(imo1.eq.5) then
           write(adate(4:6),'(a3)') 'May'
        elseif(imo1.eq.6) then
           write(adate(4:6),'(a3)') 'Jun'
        elseif(imo1.eq.7) then
           write(adate(4:6),'(a3)') 'Jul'
        elseif(imo1.eq.8) then
           write(adate(4:6),'(a3)') 'Aug'
        elseif(imo1.eq.9) then
           write(adate(4:6),'(a3)') 'Sep'
        elseif(imo1.eq.10) then
           write(adate(4:6),'(a3)') 'Oct'
        elseif(imo1.eq.11) then
           write(adate(4:6),'(a3)') 'Nov'
        elseif(imo1.eq.12) then
           write(adate(4:6),'(a3)') 'Dec'
        endif
c year, this will work if our year is 2 digit and up till 2099
       if(iyr1.le.9) then
           write(adate(11:11),'(i1)') iyr1       
       elseif(iyr1.ge.10) then
           write(adate(10:11),'(i2)') iyr1       
       endif

       write(adate(12:12),'(a1)') '-'
        write(adate(13:14),'(i2)') idy2
        if(imo2.eq.1) then
           write(adate(16:18),'(a3)') 'Jan'
        elseif(imo2.eq.2) then
           write(adate(16:18),'(a3)') 'Feb'
        elseif(imo2.eq.3) then
           write(adate(16:18),'(a3)') 'Mar'
        elseif(imo2.eq.4) then
           write(adate(16:18),'(a3)') 'Apr'
        elseif(imo2.eq.5) then
           write(adate(16:18),'(a3)') 'May'
        elseif(imo2.eq.6) then
           write(adate(16:18),'(a3)') 'Jun'
        elseif(imo2.eq.7) then
           write(adate(16:18),'(a3)') 'Jul'
        elseif(imo2.eq.8) then
           write(adate(16:18),'(a3)') 'Aug'
        elseif(imo2.eq.9) then
           write(adate(16:18),'(a3)') 'Sep'
        elseif(imo2.eq.10) then
           write(adate(16:18),'(a3)') 'Oct'
        elseif(imo2.eq.11) then
           write(adate(16:18),'(a3)') 'Nov'
        elseif(imo2.eq.12) then
           write(adate(16:18),'(a3)') 'Dec'
        endif
       write(*,*) iyr2
c year, this will work if our year is 2 digit and up till 2099
       if(iyr1.le.9) then
           write(adate(23:23),'(i1)') iyr2       
       elseif(iyr1.ge.10) then
           write(adate(22:23),'(i2)') iyr2       
       endif
       return
       end
c--------------------------------------------------------------------------
        subroutine decodeship(ashipname,shipname,ierr,l2)
        character*3 ashipname, shipname*30

        ierr = 0

           if(ashipname(1:3).eq.'AS ') then
              shipname(1:16) = 'Argentina Star, '
              l2 = 16
           elseif(ashipname(1:3).eq.'BS ') then
              shipname(1:15) = 'Brisbane Star, '
              l2 = 15
           elseif(ashipname(1:3).eq.'CS ') then
              shipname(1:17) = 'California Star, '
              l2 = 17
           elseif(ashipname(1:3).eq.'SS ') then
              shipname(1:16) = 'Southland Star, '
              l2 = 16
           elseif(ashipname(1:3).eq.'FL ') then
              shipname(1:9) = 'Florida, '
              l2 = 9
           elseif(ashipname(1:3).eq.'JB ') then
              shipname(1:14) = 'Joana Bonita, '
              l2 = 14
           elseif(ashipname(1:3).eq.'A10') then
              shipname(1:8) = 'Act 10, '
              l2 = 8
           elseif(ashipname(1:3).eq.'A  ') then
              shipname(1:11) = 'Astrolabe, '
              l2 = 11
           elseif(ashipname(1:3).eq.'BH ') then
              shipname(1:13) = 'Bouvenhusen, '
              l2 = 13
           elseif(ashipname(1:3).eq.'FK ') then
              shipname(1:13) = 'Fua Kavenga, '
              l2 = 13
           elseif(ashipname(1:3).eq.'SM ') then
              shipname(1:16) = 'Southern Moana, '
              l2 = 16
           elseif(ashipname(1:3).eq.'SQ ') then
              shipname(1:16) = 'Southern Queen, '
              l2 = 16
           elseif(ashipname(1:3).eq.'EB ') then
              shipname(1:15) = 'Encounter Bay, '
              l2 = 15
           elseif(ashipname(1:3).eq.'ID ') then
              shipname(1:14) = 'Iron Dampier, '
              l2 = 14
           elseif(ashipname(1:3).eq.'IF ') then
              shipname(1:15) = 'Iron Flinders, '
              l2 = 15
           elseif(ashipname(1:3).eq.'R  ') then
              shipname(1:11) = 'Rangitane, '
              l2 = 11
           elseif(ashipname(1:3).eq.'Rta') then
              shipname(1:11) = 'Rangitata, '
              l2 = 11
           elseif(ashipname(1:3).eq.'Rui') then
              shipname(1:10) = 'Ranginui, '
              l2 = 10
           elseif(ashipname(1:3).eq.'SE ') then
              shipname(1:20) = 'SeaLand Enterprise, '
              l2 = 20
           elseif(ashipname(1:3).eq.'T  ') then
              shipname(1:10) = 'Tonsina, '
              l2 = 10
           elseif(ashipname(1:3).eq.'CM ') then
              shipname(1:21) = 'Chevron Mississippi, '
              l2 = 21
           elseif(ashipname(1:3).eq.'KM ') then
              shipname(1:12) = 'Kilo Moana, '
              l2 = 12
           elseif(ashipname(1:3).eq.'AC ') then
              shipname(1:18) = 'Asian Challenger, '
              l2 = 18
           elseif(ashipname(1:3).eq.'N  ') then
              shipname(1:11) = 'NYK Nacre, '
              l2 = 11
           elseif(ashipname(1:3).eq.'Rra') then
              shipname(1:10) = 'Rangiora, '
              l2 = 10
           elseif(ashipname(1:3).eq.'LO ') then
              shipname(1:18) = 'Lydia Oldendorff, '
              l2 = 18
           elseif(ashipname(1:3).eq.'CE ') then
              shipname(1:17) = 'CSX Enterprise, '
              l2 = 17
           elseif(ashipname(1:3).eq.'CC ') then
              shipname(1:21) = 'Columbus Coromandel, '
              l2 = 21
           elseif(ashipname(1:3).eq.'LMG') then
              shipname(1:9) = 'LMGould, '
              l2 = 9
           elseif(ashipname(1:3).eq.'WE ') then
              shipname(1:20) = 'Wellington Express, '
              l2 = 20
           elseif(ashipname(1:3).eq.'KC ') then
              shipname(1:14) = 'Kakapo Chief, '
              l2 = 14
           elseif(ashipname(1:3).eq.'CF ') then
              shipname(1:18) = 'Columbus Florida, '
              l2 = 18
           elseif(ashipname(1:3).eq.'MK ') then
              shipname(1:11) = 'MOL Kauri, '
              l2 = 11
           elseif(ashipname(1:3).eq.'   ') then
              shipname(1:15) = 'Forum Samoa 2, '
              l2 = 15
           elseif(ashipname(1:3).eq.'PD ') then
              shipname(1:16) = 'M/V Polar Duke, '
              l2 = 16
           elseif(ashipname(1:3).eq.'NBP') then
              shipname(1:21) = 'Nathaniel B Palmer, '
              l2 = 21
           elseif(ashipname(1:3).eq.'OB ') then
              shipname(1:17) = 'Overseas Boston, '
              l2 = 17
           elseif(ashipname(1:3).eq.'CT ') then
              shipname(1:18) = 'Capitaine Tasman, '
              l2 = 18
           elseif(ashipname(1:3).eq.'FR ') then
              shipname(1:10) = 'Franklin, '
              l2 = 10
           elseif(ashipname(1:3).eq.'FT ') then
              shipname(1:13) = 'Forum Tonga, '
              l2 = 13
           elseif(ashipname(1:3).eq.'FS ') then
              shipname(1:15) = 'Forum Samoa 2, '
              l2 = 15
           elseif(ashipname(1:3).eq.'CCh') then
              shipname(1:13) = 'Coral Chief, '
              l2 = 13
           elseif(ashipname(1:3).eq.'CA ') then
              shipname(1:12) = 'Conti Asia, '
              l2 = 12
           elseif(ashipname(1:3).eq.'NN ') then
              shipname(1:17) = 'Nedlloyd Nelson, '
              l2 = 17
           elseif(ashipname(1:3).eq.'NT ') then
              shipname(1:17) = 'Nedlloyd Tasman, '
              l2 = 17
           elseif(ashipname(1:3).eq.'NP ') then
              shipname(1:14) = 'New Plymouth, '
              l2 = 14
           elseif(ashipname(1:3).eq.'PM ') then
              shipname(1:15) = 'PONL Mairangi, '
              l2 = 15
           elseif(ashipname(1:3).eq.'AP ') then
              shipname(1:14) = 'ANL Progress, '
              l2 = 14
           elseif(ashipname(1:3).eq.'DT ') then
              shipname(1:12) = 'Direct Tui, '
              l2 = 12
           elseif(ashipname(1:3).eq.'MC ') then
              shipname(1:17) = 'Marine Columbia, '
              l2 = 17
           elseif(ashipname(1:3).eq.'MF ') then
              shipname(1:14) = 'MSC Federica, '
              l2 = 14
           elseif(ashipname(1:3).eq.'MD ') then
              shipname(1:11) = 'MSC Didem, '
              l2 = 11
           elseif(ashipname(1:3).eq.'HE ') then
              shipname(1:20) = 'Horizon Enterprise, '
              l2 = 20
           elseif(ashipname(1:3).eq.'FD ') then
              shipname(1:19) = 'Forestal Diamante, '
              l2 = 19
           elseif(ashipname(1:3).eq.'NW ') then
              shipname(1:21) = 'Nedlloyd Wellington, '
              l2 = 21
           elseif(ashipname(1:3).eq.'SA ') then
              shipname(1:16) = 'Seabulk Arctic, '
              l2 = 16
           elseif(ashipname(1:3).eq.'SP ') then
              shipname(1:15) = 'Seabulk Pride, '
              l2 = 15
           elseif(ashipname(1:3).eq.'MA ') then
              shipname(1:17) = 'Maersk Auckland, '
              l2 = 17
           elseif(ashipname(1:3).eq.'DC ') then
              shipname(1:15) = 'Direct Condor, '
              l2 = 15
           else
              write(*,*) 'I do not know this ship:', ashipname(1:3)
              ierr = 1
           endif
        return
        end

        subroutine createpos(xg,dis,dis1,ns,orient,trkpos)
! input:
! create matching lat or lon (depending on orient=lat or lon) for .1 deg track
! xg is our .1 deg along track latitude or longitude
! dis is the XBT positions in whatever xg is refering to (lat or lon)
! dis1 is the "other" xbt position identifer (either lat or lon)
! ns= number of xbts positions in dis/dis1
!
! output:
!trkpos, hopefully linearly interpolated lat or lon to match xg
        
        dimension dis(600), dis1(600)
        character*3 orient
!
!17dec2010        if(orient.eq.'lat') then
!17dec2010           stop 'code linear interp for lat!'
!17dec2010        elseif(orient.eq.'lon') then
! xg is longitude of .1 deg track position
! dis is longs of all XBT
! dis1 is lats of all XBTs
! find surrounding dis() longs to xg:
           do 10 i = 1, ns
             if(dis(i).eq.xg) then
                trkpos = dis1(i)
                go to 100
             elseif(dis(i).lt.xg) then
                xmin = dis(i)
                ymin = dis1(i)
             elseif(dis(i).gt.xg) then
                xmax = dis(i)
                ymax = dis1(i)
                go to 11 
             endif
10         continue
11         continue
!           write(33,*)'trkpos', xg, xmin, xmax, ymin, ymax
           frac = (xg-xmin)/(xmax-xmin)
           trkpos = ymin + ( ymax - ymin )*frac

!17dec2010        endif

100     continue
        return
        end
