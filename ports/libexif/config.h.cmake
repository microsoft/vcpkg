/* config.h.in.  Generated from configure.ac by autoheader.  */

/* Define to 1 if translation of program messages to the user's native
   language is requested. */
#cmakedefine ENABLE_NLS

/* Define if the GNU dcgettext() function is already present or preinstalled.
   */
#cmakedefine HAVE_DCGETTEXT

/* Define to 1 if you have the <dlfcn.h> header file. */
#cmakedefine HAVE_DLFCN_H

/* Define if the GNU gettext() function is already present or preinstalled. */
#cmakedefine HAVE_GETTEXT

/* Define if you have the iconv() function. */
#cmakedefine HAVE_ICONV

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine HAVE_INTTYPES_H

/* Define to 1 if you have the `localtime_r' function. */
#cmakedefine HAVE_LOCALTIME_R

/* Define to 1 if you have the <memory.h> header file. */
#cmakedefine HAVE_MEMORY_H

/* Define to 1 if you have the <stdint.h> header file. */
#cmakedefine HAVE_STDINT_H

/* Define to 1 if you have the <stdlib.h> header file. */
#cmakedefine HAVE_STDLIB_H

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H

/* Define to 1 if you have the <string.h> header file. */
#cmakedefine HAVE_STRING_H

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine HAVE_SYS_STAT_H

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H

/* Define as const if the declaration of iconv() needs const. */
#cmakedefine ICONV_CONST

/* Define to the sub-directory in which libtool stores uninstalled libraries.
   */
#cmakedefine LT_OBJDIR

/* Name of package */
#cmakedefine PACKAGE

/* Define to the address where bug reports for this package should be sent. */
#cmakedefine PACKAGE_BUGREPORT

/* Define to the full name of this package. */
#cmakedefine PACKAGE_NAME

/* Define to the full name and version of this package. */
#cmakedefine PACKAGE_STRING

/* Define to the one symbol short name of this package. */
#cmakedefine PACKAGE_TARNAME

/* Define to the home page for this package. */
#cmakedefine PACKAGE_URL

/* Define to the version of this package. */
#cmakedefine PACKAGE_VERSION

/* Define to 1 if you have the ANSI C header files. */
#cmakedefine STDC_HEADERS

/* Version number of package */
#cmakedefine VERSION

/* Define to empty if `const' does not conform to ANSI C. */
#cmakedefine const

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
#cmakedefine inline
#endif

#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif