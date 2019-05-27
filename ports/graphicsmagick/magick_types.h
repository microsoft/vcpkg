/*
  Copyright (C) 2003 - 2012 GraphicsMagick Group
 
  This program is covered by multiple licenses, which are described in
  Copyright.txt. You should have received a copy of Copyright.txt with this
  package; otherwise see http://www.graphicsmagick.org/www/Copyright.html.
 
  GraphicsMagick types typedefs.

  GraphicsMagick is expected to compile with any C '89 ANSI C compiler
  supporting at least 16-bit 'short', 32-bit 'int', and 32-bit 'long'.
  It is also expected to take advantage of 64-bit LP64 and Windows
  WIN64 LLP64.  We use C '99 style types but declare our own types so
  as to not depend on C '99 header files, and take care to depend only
  on C '89 library functions, POSIX, or well-known extensions.  Any C
  '99 syntax used is removed if the compiler does not support it.
*/

#ifndef _MAGICK_TYPES_H
#define _MAGICK_TYPES_H

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

/*
  Assign ANSI C stdint.h-like typedefs based on the sizes of native types
  magick_int8_t   --                       -128 to 127
  magick_uint8_t  --                          0 to 255
  magick_int16_t  --                    -32,768 to 32,767
  magick_uint16_t --                          0 to 65,535
  magick_int32_t  --             -2,147,483,648 to 2,147,483,647
  magick_uint32_t --                          0 to 4,294,967,295
  magick_int64_t  -- -9,223,372,036,854,775,807 to 9,223,372,036,854,775,807
  magick_uint64_t --                          0 to 18,446,744,073,709,551,615

  magick_uintmax_t -- largest native unsigned integer type ("%ju")
                                              0 to UINTMAX_MAX
                      UINTMAX_C(value) declares constant value
  magick_uintptr_t -- unsigned type for storing a pointer value ("%tu")
                                              0 to UINTPTR_MAX

  ANSI C '99 stddef.h-like types
  size_t           -- unsigned type representing sizes of objects ("%zu")
                                              0 to SIZE_MAX
  magick_ptrdiff_t -- signed type for subtracting two pointers ("%td")
                                    PTRDIFF_MIN to PTRDIFF_MAX

  EEE Std 1003.1, 2004 types
  ssize_t          -- signed type for a count of bytes or an error indication ("%zd")
                                              ? to SSIZE_MAX
*/

#if (defined(WIN32) || defined(WIN64)) && \
  !defined(__MINGW32__) && !defined(__MINGW64__)

  /* The following typedefs are used for WIN32 & WIN64 (without
     configure) */
  typedef signed char   magick_int8_t;
  typedef unsigned char  magick_uint8_t;

  typedef signed short  magick_int16_t;
  typedef unsigned short magick_uint16_t;

  typedef signed int  magick_int32_t;
#  define MAGICK_INT32_F ""
  typedef unsigned int magick_uint32_t;
#  define MAGICK_UINT32_F ""

  typedef signed __int64  magick_int64_t;
# define MAGICK_INT64_F "I64"
  typedef unsigned __int64 magick_uint64_t;
# define MAGICK_UINT64_F "I64"

  typedef magick_uint64_t magick_uintmax_t;

#  if defined(WIN32)
  typedef unsigned long magick_uintptr_t;
#  define MAGICK_SIZE_T_F "l"
#  define MAGICK_SIZE_T unsigned long
#  define MAGICK_SSIZE_T_F "l"
#  define MAGICK_SSIZE_T long
#  elif defined(WIN64)
  /* WIN64 uses the LLP64 model */
  typedef unsigned long long magick_uintptr_t;
#  define MAGICK_SIZE_T_F "I64"
#  define MAGICK_SIZE_T unsigned __int64
#  define MAGICK_SSIZE_T_F "I64"
#  define MAGICK_SSIZE_T signed __int64
#  endif

#else

  /* The following typedefs are subtituted when using Unixish configure */
  typedef signed char   magick_int8_t;
  typedef unsigned char  magick_uint8_t;

  typedef signed short  magick_int16_t;
  typedef unsigned short magick_uint16_t;

  typedef signed int  magick_int32_t;
#  define MAGICK_INT32_F ""
  typedef unsigned int magick_uint32_t;
#  define MAGICK_UINT32_F ""

  typedef signed long  magick_int64_t;
#  define MAGICK_INT64_F "l"
  typedef unsigned long magick_uint64_t;
#  define MAGICK_UINT64_F "l"

  typedef unsigned long magick_uintmax_t;
#  define MAGICK_UINTMAX_F "l"

  typedef unsigned long magick_uintptr_t;
#  define MAGICK_UINTPTR_F "l"

#  define MAGICK_SIZE_T_F "l"
#  define MAGICK_SIZE_T unsigned long

#  define MAGICK_SSIZE_T_F "l"
#  define MAGICK_SSIZE_T signed long

#endif

  /* 64-bit file and blob offset type */
  typedef magick_int64_t magick_off_t;
#define MAGICK_OFF_F MAGICK_INT64_F

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif /* defined(__cplusplus) || defined(c_plusplus) */

#endif /* _MAGICK_TYPES_H */
