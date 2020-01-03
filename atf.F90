MODULE ATF
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY: OUTPUT_UNIT, ERROR_UNIT
  IMPLICIT NONE

  DOUBLE PRECISION, PARAMETER :: ZERO = 0.0D+0

CONTAINS

#ifndef NDEBUG
  SUBROUTINE WRITE_DMTX(U, K, M, N, A, LDA)
    ! Copyright (c) 2020 Vedran Novaković <venovako@venovako.eu>
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: U, K, M, N, LDA
    DOUBLE PRECISION, INTENT(IN) :: A(LDA,N)

    INTEGER :: I, J

    WRITE (U,'(A,I2)') 'iteration', K
    FLUSH(U)

    DO I = 1, M
       WRITE (U,'(I1)',ADVANCE='NO') I
       FLUSH(U)

       DO J = 1, N
          WRITE (U,'(ES26.17E3)',ADVANCE='NO') A(I,J)
          FLUSH(U)
       END DO

       WRITE (U,*)
       FLUSH(U)
    END DO
  END SUBROUTINE WRITE_DMTX
#endif

  SUBROUTINE DATF(N, A, LDA, TOL, D, V, INFO)
    ! Copyright (c) 2020 Sanja Singer <ssinger@fsb.hr> and Vedran Novaković <venovako@venovako.eu>
    ! A is a full skew-symmetric double precision matrix on input,
    ! and a skew-symmetric, upper anti-triangular matrix on output.
    ! TOL is a parameter such that the final anti-diagonal entries are considered
    ! to be (and are set to) zero if their magnitudes are not greater than TOL.
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: N, LDA
    INTEGER, INTENT(OUT) :: INFO
    DOUBLE PRECISION, INTENT(IN) :: TOL
    DOUBLE PRECISION, INTENT(INOUT) :: A(LDA,N)
    DOUBLE PRECISION, INTENT(OUT) :: D(N), V(N-1)

    INTEGER :: K, I, L, I1, I2, IMAX, STP
    DOUBLE PRECISION :: DP

    INTEGER, EXTERNAL :: IDAMAX
    DOUBLE PRECISION, EXTERNAL :: DNRM2, DDOT
    EXTERNAL :: DSWAP, DCOPY, DAXPY

    IF (N .LT. 0) THEN
       INFO = -1
    ELSE IF (LDA .LT. N) THEN
       INFO = -3
    ELSE IF (.NOT. (TOL .GE. ZERO)) THEN
       INFO = -4
    ELSE ! all OK
       INFO = 0
    END IF
    IF (N .LT. 3) RETURN

    DO STP = 1, N/2
       I1 = STP
       I2 = N - STP + 1
       L = I2 - I1 + 1
       DO K = I1, I2
          D(K) = DNRM2(L, A(I1,K), 1)
          IF (.NOT. (D(K) .LE. HUGE(ZERO))) THEN
             INFO = -(K + 4)
             GOTO 1
          END IF
       END DO
       IMAX = IDAMAX(L, D(I1), 1) + I1 - 1
       IF (IMAX .NE. I2) THEN
          CALL DSWAP(N, A(1,IMAX), 1, A(1,I2), 1)
          CALL DSWAP(N, A(IMAX,1), LDA, A(I2,1), LDA)
       END IF
       CALL DCOPY(L-1, A(I1,I2), 1, V(I1), 1)
       V(I1) = V(I1) + SIGN(D(IMAX), V(I1))
       DP = DNRM2(L-1, V(I1), 1)
       IF (DP .GT. ZERO) THEN
          DO I = I1, I1+L-2
             V(I) = V(I) / DP
          END DO
          ! apply the Householder reflector from the left
          DO I = 1, I2
             DP = -SCALE(DDOT(L-1, V(I1), 1, A(I1,I), 1), 1)
             CALL DAXPY(L-1, DP, V(I1), 1, A(I1,I), 1)
          END DO
          DO I = I1+1, I2
             A(I,I2) = ZERO
          END DO
          ! apply the Householder reflector from the right
          DO I = 1, I2
             DP = -SCALE(DDOT(L-1, V(I1), 1, A(I,I1), LDA), 1)
             CALL DAXPY(L-1, DP, V(I1), 1, A(I,I1), LDA)
          END DO
          DO I = I1+1, I2-1
             A(I2,I) = ZERO
          END DO
          ! skew-symmetrize
          DO I = 1, I2-1
             DO K = 1, I-1
                A(I,K) = SCALE(A(I,K)-A(K,I), -1)
                A(K,I) = -A(I,K)
             END DO
             A(I,I) = ZERO
          END DO
       ELSE
          INFO = STP
       END IF
1      CONTINUE
#ifndef NDEBUG
       CALL WRITE_DMTX(OUTPUT_UNIT, STP, N, N, A, LDA)
#endif
       IF (INFO .LT. 0) RETURN
       IF (INFO .GT. 0) EXIT
    END DO

    INFO = N
    DO I = 1, N
       K = N - I + 1
       IF (ABS(A(I,K)) .LE. TOL) THEN
          A(I,K) = SIGN(ZERO, A(I,K))
          INFO = INFO - 1
       END IF
    END DO
  END SUBROUTINE DATF

  SUBROUTINE DATP(N, A, LDA, TOL, D, V, INFO)
    ! Copyright (c) 2020 Sanja Singer <ssinger@fsb.hr> and Vedran Novaković <venovako@venovako.eu>
    ! A is a full skew-symmetric double precision matrix on input,
    ! and a skew-symmetric, upper anti-triangular matrix on output.
    ! TOL is a parameter such that the column norms are considered
    ! to be (and are set to) zero if they are not greater than TOL.
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: N, LDA
    INTEGER, INTENT(OUT) :: INFO
    DOUBLE PRECISION, INTENT(IN) :: TOL
    DOUBLE PRECISION, INTENT(INOUT) :: A(LDA,N)
    DOUBLE PRECISION, INTENT(OUT) :: D(N), V(N-1)

    INTEGER :: K, I, L, I1, I2, IMAX, STP
    DOUBLE PRECISION :: DP

    INTEGER, EXTERNAL :: IDAMAX
    DOUBLE PRECISION, EXTERNAL :: DNRM2, DDOT
    EXTERNAL :: DSWAP, DCOPY, DAXPY

    IF (N .LT. 0) THEN
       INFO = -1
    ELSE IF (LDA .LT. N) THEN
       INFO = -3
    ELSE IF (.NOT. (TOL .GE. ZERO)) THEN
       INFO = -4
    ELSE ! all OK
       INFO = 0
    END IF
    IF (N .LT. 3) RETURN

    INFO = -2
    DO STP = 1, N/2
       I1 = STP
       I2 = N - STP + 1
       L = I2 - I1 + 1
       DO K = I1, I2
          D(K) = DNRM2(L, A(I1,K), 1)
          IF (.NOT. (D(K) .LE. HUGE(ZERO))) THEN
             INFO = -(K + 4)
             GOTO 2
          END IF
       END DO
       IMAX = IDAMAX(L, D(I1), 1) + I1 - 1
       IF (IMAX .NE. I2) THEN
          CALL DSWAP(N, A(1,IMAX), 1, A(1,I2), 1)
          CALL DSWAP(N, A(IMAX,1), LDA, A(I2,1), LDA)
          DP = D(I2)
          D(I2) = D(IMAX)
          D(IMAX) = DP
       END IF
       IF (D(I2) .GT. TOL) THEN
          CALL DCOPY(L-1, A(I1,I2), 1, V(I1), 1)
          V(I1) = V(I1) + SIGN(D(I2), V(I1))
          DP = DNRM2(L-1, V(I1), 1)
          IF (DP .GT. ZERO) THEN
             DO I = I1, I1+L-2
                V(I) = V(I) / DP
             END DO
             ! apply the Householder reflector from the left
             DO I = 1, I2
                DP = -SCALE(DDOT(L-1, V(I1), 1, A(I1,I), 1), 1)
                CALL DAXPY(L-1, DP, V(I1), 1, A(I1,I), 1)
             END DO
             DO I = I1+1, I2
                A(I,I2) = ZERO
             END DO
             ! apply the Householder reflector from the right
             DO I = 1, I2
                DP = -SCALE(DDOT(L-1, V(I1), 1, A(I,I1), LDA), 1)
                CALL DAXPY(L-1, DP, V(I1), 1, A(I,I1), LDA)
             END DO
             DO I = I1+1, I2-1
                A(I2,I) = ZERO
             END DO
             ! skew-symmetrize
             DO I = 1, I2-1
                DO K = 1, I-1
                   A(I,K) = SCALE(A(I,K)-A(K,I), -1)
                   A(K,I) = -A(I,K)
                END DO
                A(I,I) = ZERO
             END DO
          ELSE
             INFO = STP
          END IF
       ELSE ! near-to-zero max column norm
          DO K = I1, I2
             DO I = I1, K
                A(I,K) = ZERO
             END DO
             DO I = K+1, I2
                A(I,K) = ZERO
             END DO
          END DO
          INFO = STP
       END IF
2      CONTINUE
#ifndef NDEBUG
       CALL WRITE_DMTX(OUTPUT_UNIT, STP, N, N, A, LDA)
#endif
       IF ((INFO .LT. 0) .AND. (INFO .NE. -2)) RETURN
       IF (INFO .GT. 0) EXIT
    END DO

    IF (INFO .EQ. -2) THEN
       INFO = N - MOD(N, 2)
    ELSE ! clean up the remaining matrix
       INFO = (INFO - 1) * 2
       I2 = I1
       L = L + 1
       DO K = I1-1, 1, -1
          D(K) = DNRM2(L, A(I2,K), 1)
          CALL DCOPY(L, A(I2,K), 1, V, 1)
          V(1) = V(1) + SIGN(D(K), V(1))
          DP = DNRM2(L, V, 1)
          IF (DP .GT. ZERO) THEN
             DO I = 1, L
                V(I) = V(I) / DP
             END DO
             ! apply the Householder reflector from the left
             DO I = 1, K
                DP = -SCALE(DDOT(L, V, 1, A(I2,I), 1), 1)
                CALL DAXPY(L, DP, V, 1, A(I2,I), 1)
             END DO
             DO I = I2+1, I2+L-1
                A(I,K) = ZERO
             END DO
             ! apply the Householder reflector from the right
             DO I = 1, K
                DP = -SCALE(DDOT(L, V, 1, A(I,I2), LDA), 1)
                CALL DAXPY(L, DP, V, 1, A(I,I2), LDA)
             END DO
             DO I = I2+1, I2+L-1
                A(K,I) = ZERO
             END DO
             ! skew-symmetrize
             DO I = I2, I2+L-1
                DO STP = 1, K
                   A(I,STP) = SCALE(A(I,STP)-A(STP,I), -1)
                   A(STP,I) = -A(I,STP)
                END DO
             END DO
          ELSE ! nothing more to do
             RETURN
          END IF
          I2 = I2 + 1
       END DO
    END IF
  END SUBROUTINE DATP
END MODULE ATF
