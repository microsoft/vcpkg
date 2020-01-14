#pragma once
#include "openblas/openblas_config.h"

#if defined(OPENBLAS_OS_WINNT) || defined(OPENBLAS_OS_CYGWIN_NT) || defined(OPENBLAS_OS_INTERIX)
#define OPENBLAS_WINDOWS_ABI
#define OPENBLAS_OS_WINDOWS

#ifdef DOUBLE
#define DOUBLE_DEFINED DOUBLE
#undef  DOUBLE
#endif
#endif

#ifdef NEEDBUNDERSCORE
#define BLASFUNC(FUNC) FUNC##_
#else
#define BLASFUNC(FUNC) FUNC
#endif


#ifdef OPENBLAS_QUAD_PRECISION
typedef struct {
  unsigned long x[2];
}  xdouble;
#elif defined OPENBLAS_EXPRECISION
#define xdouble long double
#else
#define xdouble double
#endif

#if defined(OS_WINNT) && defined(__64BIT__)
typedef long long BLASLONG;
typedef unsigned long long BLASULONG;
#else
typedef long BLASLONG;
typedef unsigned long BLASULONG;
#endif

#ifdef OPENBLAS_USE64BITINT
typedef BLASLONG blasint;
#else
typedef int blasint;
#endif

#if defined(XDOUBLE) || defined(DOUBLE)
#define FLOATRET	FLOAT
#else
#ifdef NEED_F2CCONV
#define FLOATRET	double
#else
#define FLOATRET	float
#endif
#endif


/* Inclusion of a standard header file is needed for definition of __STDC_*
   predefined macros with some compilers (e.g. GCC 4.7 on Linux).  This occurs
   as a side effect of including either <features.h> or <stdc-predef.h>. */
#include <stdio.h>
#ifndef OPENBLAS_COMPLEX_STRUCT
#define OPENBLAS_COMPLEX_STRUCT
typedef struct { float real, imag; } openblas_complex_float;
typedef struct { double real, imag; } openblas_complex_double;
typedef struct { xdouble real, imag; } openblas_complex_xdouble;
#define openblas_make_complex_float(real, imag)    {(real), (imag)}
#define openblas_make_complex_double(real, imag)   {(real), (imag)}
#define openblas_make_complex_xdouble(real, imag)  {(real), (imag)}
#define openblas_complex_float_real(z)             ((z).real)
#define openblas_complex_float_imag(z)             ((z).imag)
#define openblas_complex_double_real(z)            ((z).real)
#define openblas_complex_double_imag(z)            ((z).imag)
#define openblas_complex_xdouble_real(z)           ((z).real)
#define openblas_complex_xdouble_imag(z)           ((z).imag)
#endif