#ifndef CONFIG_H
#define CONFIG_H

/* Define to 1 if translation of program messages to the user's native language is requested. */
#cmakedefine ENABLE_NLS 1

/* Define if the GNU dcgettext() function is already present or preinstalled. */
#cmakedefine HAVE_DCGETTEXT 1

/* Define to 1 if you have the <float.h> header file. */
#cmakedefine HAVE_FLOAT_H 1

/* Define to 1 if you have the <fnmatch.h> header file. */
#cmakedefine HAVE_FNMATCH_H 1

/* Define if the GNU gettext() function is already present or preinstalled. */
#cmakedefine HAVE_GETTEXT 1

/* Define to 1 if you have the <glob.h> header file. */
#cmakedefine HAVE_GLOB_H 1

/* Define if you have the iconv() function and it works. */
#cmakedefine HAVE_ICONV 1

/* Define to 1 if you have the <langinfo.h> header file. */
#cmakedefine HAVE_LANGINFO_H 1

/* Define to 1 if you have the <libintl.h> header file. */
#cmakedefine HAVE_LIBINTL_H 1

/* Define to 1 if you have the <mcheck.h> header file. */
#cmakedefine HAVE_MCHECK_H 1

/* Define to 1 if you have the `mtrace' function. */
#cmakedefine HAVE_MTRACE 1

/* Define to 1 if you have the `srandom' function. */
#cmakedefine HAVE_SRANDOM 1

/* Define to 1 if you have the `stpcpy' function. */
#cmakedefine HAVE_STPCPY 1

/* Define to 1 if you have the `strerror' function. */
#cmakedefine HAVE_STRERROR 1

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H 1

/* Define to 1 if you have the `vasprintf' function. */
#cmakedefine HAVE_VASPRINTF 1

/* Define to 1 if you have the `__secure_getenv' function. */
#cmakedefine HAVE___SECURE_GETENV 1

/* Name of package */
#cmakedefine PACKAGE "@PACKAGE@"

/* Full path to default POPT configuration directory */
#cmakedefine POPT_SYSCONFDIR "@POPT_SYSCONFDIR@"

#endif