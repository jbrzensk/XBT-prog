       program interp_to_grid
! 12jul20-19 fix mods for p13
!23may2012 LL - try using p09.ts for p06 loop cruises
! 7may2009 LL - John Gilson's program to read a gridded ts file to 
! create our .10s for each cruise.
! Add for p37 - choice to use:
! 1) ../p37_historical.ts  => .10s and .10v
! 2) ../p37_argo.ts        => .10sargo and .10vargo
! 3) ../p37_probably_argo.ts        => .10sargo and .10vargo
! 04feb2004 LL - allow this to run on a line named "p08".   Previously
! only ran on "p50" and "p81".   I dont think it needs any other 
! changes for p08...

! Note: this program looks for the .ts file one directory above.
!
!  takes temperature from xbt data and gives a salinity and standard
!  deviation (creates .10s and .10v files from .10 files)
!
! ntemp = # temps for each drop (from .10 file)
! num = # of ts data pairs for each square (from .ts file)
! nsq = # data squares (changes for each track)
! xbtmiss = no data value
! xsq = square lat/lon width
! tempspace = temperature grid spacing

       parameter(ntemp=90, num=161,nsqmx=1000000)
       parameter(xbtmiss=-.999)
       parameter(tempspace=0.2)

       dimension temp(ntemp), sal(ntemp), var(ntemp)
       dimension x(num), sal1(num,nsqmx), var1(num,nsqmx)
       dimension isal(num), ivar(num)
       dimension glat(nsqmx), glon(nsqmx),salc(num),varc(num)
       character filen*30, sfilen*12, vfilen*12
       character sfilenargo*16, vfilenargo*16
       character tsfilen*20
        integer isal,ivar,nsqur,nsqlr,nsqll,nsqul

       data tsfilen/'../p09.ts           '/
!       data filen /'/data/xbt/p37/0811/p370811a.10'/
!                  '1234567890123456789012345678901 
       data filen /'p370811a.10'/
!                  '12345678901 
       data sfilen /'p370811a.10s'/
       data sfilenargo /'p370811a.10sargo'/
       data vfilen /'p370811a.10v'/
       data vfilenargo /'p370811a.10vargo'/
       data xnovalue/9.99/,deg2rad/0.0174444/

1       write(*,*) ' Enter cruise name (8 chars) (ie, p319105a):'
        read(5,'(a8)') filen(1:8) 
        !write(filen(15:18),'(a4)')filen(23:26)
        !write(filen(11:13),'(a3)')filen(20:22)
! NO        if(filen(20:22).eq.'p13') filen(11:13) = 'p09'
        sfilen(1:8) = filen(1:8)
        vfilen(1:8) = filen(1:8)
        tsfilen(4:6) = filen(1:3)
! 23may2012 LL:
        if(filen(1:3).eq.'p06'.or.filen(1:3).eq.'p13') then
           tsfilen(1:20) = '../../p09/p09.ts'
        endif
      
        open(22,file=filen,form='formatted',status='old')
! If PX37, ask if using historical ts or argo ts:
        its = 1
        if(sfilen(1:3).eq.'p37') then
         write(*,*) ' p37: Which ts to use? '
         write(*,*) ' 1 = p37_historical.ts2009 '
         write(*,*) ' 2 = p37_argo ts           '
         write(*,*) ' 3 = p37_prob_argo ts 2011 '
         read(5,'(i1)') its
        endif

! its=1 = historical ts, all normal:
        if(its.eq.1) then
         if(sfilen(1:3).eq.'p37') tsfilen(7:20) = '_historical.ts'
         open(24,file=sfilen,form='formatted',status='unknown')
         open(26,file=vfilen,form='formatted',status='unknown')
        elseif(its.eq.2) then
! its=2 = argo ts, all names are argo:
         if(sfilen(1:3).eq.'p37') tsfilen(7:20) = '_argo.ts      '
         sfilenargo(1:8) = filen(1:8)
         vfilenargo(1:8) = filen(1:8)
         open(24,file=sfilenargo,form='formatted',status='unknown')
         open(26,file=vfilenargo,form='formatted',status='unknown')
! its=3 = this ts popped up in june2011, I think it's another argo...
        elseif(its.eq.3) then
         if(sfilen(1:3).eq.'p37') tsfilen(7:20) = '.ts           '
         sfilen(1:8) = filen(1:8)
         sfilen(11:12) = 'x'
         vfilen(1:8) = filen(1:8)
         vfilen(11:12) = 'y'
         open(24,file=sfilen,form='formatted',status='unknown')
         open(26,file=vfilen,form='formatted',status='unknown')
        endif
!
        open(23,file=tsfilen,status='old',form='formatted')

c read starting temp, ending temp from interpolated data from hydrosearch
c xnovalue is value given to sal & var if no data there
c       read(23,*) xstart1, xend1, num1
       xstart1=-2.
       xend1=30.
       num1=161
       do 126 k = 1, num1
         x(k) = xstart1+(k-1)*(xend1-xstart1)/(num1-1)
c         write(*,*)x(k)
126    continue

c begin ts section
c this is bulky but is for uneven (random) grids
c find the nearest t/s grids in each quadrant
c lower left quadrant

        write(*,*)
        write(*,*)'Reading in historical'
c read in historical grid data
       do 36 k=1,1000000
          read(23,124,err=37,end=37)glat(k),glon(k)
124       format(6x,2f8.3)
          nsq=k
          do 38 j=1,num1
            read(23,'(33x,2f11.6)')sal1(j,k),var1(j,k)
c            write(*,'(33x,2f11.6)')sal1(j,k),var1(j,k)
38        continue
36     continue
37     close(23)
       write(*,*)'Number of historical data is ',nsq
c       pause

c read number of xbt's 
       read(22,*) nxbt
       write(24,'(i3)') nxbt
       write(26,'(i3)') nxbt
       do 200 j = 1, nxbt
          read(22,*) xlat, xlon
          write(*,*)xlat,xlon

c begin ts section
c this is bulky but is for uneven (random) grids
c find the nearest t/s grids in each quadrant
c lower left quadrant
          distll=999999.
          nsqll=-99
          do 86 k=1,nsq
            if(xlat.gt.glat(k).and.xlon.ge.glon(k))then
              avlat=(glat(k)+xlat)/2.
              dist=sqrt((glat(k)-xlat)**2+
     $(cos(avlat*deg2rad)*(glon(k)-xlon))**2)
              if(dist.lt.distll)then
                distll=dist
                nsqll=k
              endif
            endif
86          continue
c upper left quadrant
          distul=999999.
          nsqul=-99
          do 87 k=1,nsq
            if(xlat.le.glat(k).and.xlon.gt.glon(k))then
              avlat=(glat(k)+xlat)/2.
              dist=sqrt((glat(k)-xlat)**2+
     $(cos(avlat*deg2rad)*(glon(k)-xlon))**2)
              if(dist.lt.distul)then
                distul=dist
                nsqul=k
              endif
            endif
87          continue
c lower right quadrant
          distlr=999999.
          nsqlr=-99
          do 88 k=1,nsq
            if(xlat.ge.glat(k).and.xlon.lt.glon(k))then
              avlat=(glat(k)+xlat)/2.
              dist=sqrt((glat(k)-xlat)**2+
     $(cos(avlat*deg2rad)*(glon(k)-xlon))**2)
              if(dist.lt.distlr)then
                distlr=dist
                nsqlr=k
              endif
            endif
88          continue
c upper right quadrant
          distur=999999.
          nsqur=-99
          do 89 k=1,nsq
            if(xlat.lt.glat(k).and.xlon.le.glon(k))then
              avlat=(glat(k)+xlat)/2.
              dist=sqrt((glat(k)-xlat)**2+
     $(cos(avlat*deg2rad)*(glon(k)-xlon))**2)
              if(dist.lt.distur)then
                distur=dist
                nsqur=k
              endif
            endif
89          continue


          if(nsqur.eq.-99.or.nsqul.eq.-99.or.
     $nsqlr.eq.-99.or.nsqll.eq.-99)then

          write(*,*)'XBT outside T/S defined grid'
c if any of the quadrants are undefined, then do a stupid weighted average
          do 94 kk=1,num1
           salc(kk)=0. 
           varc(kk)=0. 
           distt=0.
           if(nsqur.gt.-90)then
             salc(kk)=salc(kk)+sal1(kk,nsqur)/max(distur,.001)
             varc(kk)=varc(kk)+var1(kk,nsqur)/max(distur,.001)
             distt=distt+1./max(distur,.001)
c             write(*,*)nsqur,distur,sal1(1,nsqur)
           endif
           if(nsqul.gt.-90)then
             salc(kk)=salc(kk)+sal1(kk,nsqul)/max(distul,.001)
             varc(kk)=varc(kk)+var1(kk,nsqul)/max(distul,.001)
             distt=distt+1./max(distul,.001)
c             write(*,*)nsqul,distul,sal1(1,nsqul)
           endif
           if(nsqll.gt.-90)then
             salc(kk)=salc(kk)+sal1(kk,nsqll)/max(distll,.001)
             varc(kk)=varc(kk)+var1(kk,nsqll)/max(distll,.001)
             distt=distt+1./max(distll,.001)
c             write(*,*)nsqll,distll,sal1(1,nsqll)
           endif
           if(nsqlr.gt.-90)then
             salc(kk)=salc(kk)+sal1(kk,nsqlr)/max(distlr,.001)
             varc(kk)=varc(kk)+var1(kk,nsqlr)/max(distlr,.001)
             distt=distt+1./max(distlr,.001)
c             write(*,*)nsqlr,distlr,sal1(1,nsqlr)
           endif
           if(distt.gt.0)then
             salc(kk)=salc(kk)/distt
             varc(kk)=varc(kk)/distt
           else
             write(*,*)'failed'
!             pause
           endif
c           write(*,*)kk,salc(kk),varc(kk)
94        continue
c          pause
          else

c if all the quadrants are defined, linearly interpolate
          do 95 kk=1,num1
            top=sal1(kk,nsqul)+(xlon-glon(nsqul))/
     $(glon(nsqul)-glon(nsqur))*(sal1(kk,nsqul)-sal1(kk,nsqur))
            topv=var1(kk,nsqul)+(xlon-glon(nsqul))/
     $(glon(nsqul)-glon(nsqur))*(var1(kk,nsqul)-var1(kk,nsqur))
            tlat=glat(nsqul)+(xlon-glon(nsqul))/
     $(glon(nsqul)-glon(nsqur))*(glat(nsqul)-glat(nsqur))
c         write(*,*)top,tlat

            bot=sal1(kk,nsqll)+(xlon-glon(nsqll))/
     $(glon(nsqll)-glon(nsqlr))*(sal1(kk,nsqll)-sal1(kk,nsqlr))
            botv=var1(kk,nsqll)+(xlon-glon(nsqll))/
     $(glon(nsqll)-glon(nsqlr))*(var1(kk,nsqll)-var1(kk,nsqlr))
            blat=glat(nsqll)+(xlon-glon(nsqll))/
     $(glon(nsqll)-glon(nsqlr))*(glat(nsqll)-glat(nsqlr))
c         write(*,*)bot,blat

            salc(kk)=top-(xlat-tlat)/
     $(tlat-blat)*(bot-top)
            varc(kk)=topv-(xlat-tlat)/
     $(tlat-blat)*(botv-topv)
95          continue

          endif

c  read in temperature data from .10 file
c Note: .10 temps go from high to low (surface to bottom), *.ts files
c go from low to high, hence reading this in backwards:
          read(22,500) (temp(i), i = ntemp, 1, -1)
500       format(12f6.3)

        do 29 i=1,ntemp
          do 27 jj = 1,num1
            if(temp(i).eq.xbtmiss)then
              sal(i) = xbtmiss
              var(i) = xbtmiss
              go to 29
            endif
            if(temp(i).ge.xend1)then
              sal(i)=salc(num)
              var(i)=varc(num)
              goto29
            endif
            if(temp(i).le.xstart1)then
              sal(i)=salc(1)
              var(i)=varc(1)
              goto29
            endif

c ok, we have one, now find its little range
c and check for values
            if (x(jj).le.temp(i).and.temp(i).le.x(jj+1)) then
              if ((salc(jj).eq.xnovalue).or.
     $(salc(jj+1).eq.xnovalue)) then
                sal(i) = xbtmiss
                var(i) = xbtmiss
                print *, xlat,xl,temp(i),'not enough data'
                go to 29
              endif
c  weights for temperature
                z = x(jj+1) - x(jj)
                t2 = ( temp(i) - x(jj) )/z
                t1 = ( x(jj+1) - temp(i) ) /z
                sal(i) =  t1*salc(jj) + t2*salc(jj+1)
                var(i) =  t1*varc(jj) + t2*varc(jj+1)
              endif
27        continue
29        continue

c Put in same form as .10 files
          do 41 i = 1, ntemp
              sal(i) = sal(i)*1000.
              isal(i) = sal(i)
              var(i) = var(i)*1000.
              ivar(i) = var(i)
41       continue
          write(24,554) xlat, xlon
          write(26,554) xlat, xlon
554      format(2f9.3)
          write(24,555) (isal(i), i = ntemp, 1, -1)
          write(26,555) (ivar(i), i = ntemp, 1, -1)
555      format(12i6)

200   continue          
       close(22)
       close(24)
       close(26)
600   continue
       stop
       end
