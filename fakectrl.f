       program fakecontrol
       character*7 acruise
!p370000
! 912 800
!15000    0  ega
!  90.  -1.  10.   0.
!  300.  100.  -.00060   .00050  3.5
! 1 0.0 30.0
!UNKNOWN           
!Unknown
! 4 1
! 10.0 25.0
!C:\AUTOXBT\DATA     
!C:\AUTOXBT          
! -1 -2 -3 -4 -5 -6
       read(*,'(a7)') acruise
       open(10,file='control.dat',status='unknown',form='formatted')
       write(10,'(a7)') acruise
       write(10,'(a8)') ' 912 800'
       write(10,'(a15)')'15000    0  ega'
       write(10,'(a)')  '  90.  -1.  10.   0.'
       write(10,'(a)')  '  300.  100.  -.00060   .00050  3.5'
       write(10,'(a)')  ' 1 0.0 30.0'
       write(10,'(a)') 'UNKNOWN           '
       write(10,'(a)') 'Unknown'
       write(10,'(a)') ' 4 1'
       write(10,'(a)') ' 10.0 25.0'
       write(10,'(a)') 'C: AUTOXBT DATA     '
       write(10,'(a)') 'C: AUTOXBT          '
       write(10,'(a)') ' -1 -2 -3 -4 -5 -6'
       close(10)
       stop
       end

