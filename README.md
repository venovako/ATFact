# ATFact
The anti-triangular factorization of skew-symmetric matrices.

This software is a supplementary material for the paper
[doi:10.1016/j.amc.2020.125263](https://doi.org/10.1016/j.amc.2020.125263 "The antitriangular factorization of skew-symmetric matrices").

The preprint is available at arXiv:[1909.00092](https://arxiv.org/abs/1909.00092 "The antitriangular factorization of skew-symmetric matrices") \[math.NA\].

## Prerequisites

* Intel Math Kernel Library (MKL), or another [BLAS](https://netlib.org/blas/) library (with some tweaking of the corresponding makefile required)
  - see `nvidia.mk` for an example of using the NVIDIA-provided BLAS
* a recent Fortran compiler
  - GNU, Intel, and PGI (now NVIDIA) compilers have been confirmed to work

Optionally, for data generation, clone [JACSD](https://github.com/venovako/JACSD) repository and build sub-projects `qxblas` and `tgenskew` (in that order).

## Building

Compilation on Windows with Intel Fortran:
```bat
nmake.exe NDEBUG=3 clean all
```

Compilation on Linux/macOS with GNU Fortran:
```bash
make NDEBUG=3 clean all
```

Compilation on Linux/macOS with Intel Fortran:
```bash
make CPU=x64 NDEBUG=3 clean all
```

Compilation on Intel Xeon Phi (x200) with Intel Fortran:
```bash
make CPU=x200 NDEBUG=3 clean all
```

Compilation on Linux with NVIDIA Fortran:
```bash
make CPU=nvidia NDEBUG=4 clean all
```

## Data

Data files (`FN` = File Name, without an extension):
* `FN.S`: input
  - a binary file with an `N`x`N` `double precision` skew-symmetric matrix in column-major (Fortran) array order
* `FN.L`: auxiliary
  - a binary file with `N` `double precision` imaginary parts of the eigenvalues of `S`
* `FN.F`: output
  - a binary file with an `N`x`N` `double precision` skew-symmetric anti-upper triangular matrix in column-major (Fortran) array order

When `FN` = `N`-`K` in the provided data files in subdirectory `108`:
* `N`: order of `S`
* `K`: rank of `S`

## Execution

### DATF routine tester

Run `tatf.exe` with the following parameters:
* `FN`: as above;
* `N`: as above;
* `TOL`: the resulting anti-diagonal elements with magnitudes not greater than `TOL` are set to zeroes and the matrix rank is reduced by the number of such elements.

Output (`INFO`) indicates the rank of the resulting matrix, or an error if negative.

### DATP routine tester

Run `tatp.exe` with the following parameters:
* `FN`: as above;
* `N`: as above;
* `TOL`: a parameter such that the column norms are considered to be (and are set to) zero if they are not greater than `TOL`.

Output (`INFO`) indicates the rank of the resulting matrix with its anti-diagonals peeled off to match the rank, or an error if negative.

### DATP as a rank detector

Run `ttol.exe` with the following parameters:
* `FN`: as above;
* `N`: as above;
* `TOL`: a scale for `DATP`'s `TOL` parameter.

The effective `TOL` is then computed as:
```fortran
TOL = TOL * (MAX(NRM2S) * (N * EPSILON(1.0D0)))
```
where, for ``1 <= I <= N``,
```fortran
NRM2S(I) = DNRM2(N, S(1,I), 1)
```

Output (`INFO`) indicates the rank of the resulting matrix with its anti-diagonals peeled off to match the rank, or an error if negative.

## Misc.

``gen108.(F90|exe)`` is a generator for the eigenvalue lists of the family of inputs in subdirectory `108`.  Each non-zero eigenvalue is considered to be purely imaginary and is taken twice, once as-is, and once with the opposite sign, while the zeroes are taken once each.  The non-zero entries with the positive sign are:
```fortran
SCALE(1.0D0, -I)
```
where ``0 <= I <= K``, with `K` as above.  Each eigenvalue list is then used as an input for `dgenskew.exe` generator from `tgenskew`.

Tested on the following systems:
* Intel Xeon Phi 7210 CPU running CentOS Linux 7.7.1908 with Intel Fortran and MKL 19.1.0.166
* Intel Xeon Phi 7210 CPU running CentOS Linux 7.7.1908 with PGI Fortran 19.10 (Community Edition)
* Intel Core i7-4850HQ CPU running macOS Catalina 10.15.2 with GNU Fortran (Homebrew GCC 9.2.0_3) and Intel MKL 19.0.5.281

The results with `108` dataset are identical on all systems for the generation and the rank detection, although the `F` matrices differ.

This work has been supported in part by Croatian Science Foundation under the project IP-2014-09-3670 ([MFBDA](https://web.math.pmf.unizg.hr/mfbda/)).
