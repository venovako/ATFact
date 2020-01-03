PROGRAM GEN108
  ! Copyright (c) 2019 Vedran Novaković <venovako@venovako.eu>
  IMPLICIT NONE

  CHARACTER(LEN=11) :: FN
  INTEGER :: I, J, U

  DO I = 0, 53
     U = -1
     J = (I + 1) * 2
     IF (J .LT. 10) THEN
        WRITE (FN,'(A,I1,A)') '108-', J, '.txt'
     ELSE IF (J .LT. 100) THEN
        WRITE (FN,'(A,I2,A)') '108-', J, '.txt'
     ELSE
        WRITE (FN,'(A,I3,A)') '108-', J, '.txt'
     END IF
     OPEN(NEWUNIT=U, FILE=TRIM(FN), STATUS='REPLACE', ACTION='WRITE')

     DO J = 0, I
        WRITE (U,'(ES25.17E3)') SCALE(1.0D0, -J)
        FLUSH(U)
     END DO
     DO J = (I+1)*2+1, 108
        WRITE (U,'(ES25.17E3)') 0.0D0
        FLUSH(U)
     END DO

     CLOSE(U)
  END DO
END PROGRAM GEN108
