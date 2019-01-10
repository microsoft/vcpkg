#define RETSIGTYPE void
#define VOID_SIGHANDLER 1
#define PROTOTYPES 1
#define HAVE_ISASCII 1
#define HAVE_ISXDIGIT 1
#define HAVE_MBRLEN 1
#define HAVE_MBRTOWC 1
#define HAVE_MBRTOWC 1
#define HAVE_MBSRTOWCS 1
#define HAVE_MEMMOVE 1
#define HAVE_PUTENV 1
#define HAVE_SETENV 1
#define HAVE_SETLOCALE 1
#define HAVE_STRCOLL 1
#define STRCOLL_BROKEN 1
#define HAVE_STRPBRK 1
#define HAVE_TCGETATTR 1
#define HAVE_VSNPRINTF 1
#define HAVE_WCTOMB 1
#define HAVE_WCWIDTH 1
#define STDC_HEADERS 1
#define HAVE_LANGINFO_H 1
#define HAVE_LIMITS_H 1
#define HAVE_LOCALE_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STDARG_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_TERMIOS_H 1
#define HAVE_WCHAR_H 1
#define HAVE_WCTYPE_H 1
#define HAVE_MBSTATE_T 1
#define HAVE_LANGINFO_CODESET 1
#define VOID_SIGHANDLER 1
#define STRUCT_WINSIZE_IN_SYS_IOCTL 1
#define HAVE_GETPW_DECLS 1
#define MUST_REINSTALL_SIGHANDLERS 1
#define CTYPE_NON_ASCII 1

/* Ultrix botches type-ahead when switching from canonical to
   non-canonical mode, at least through version 4.3 */
#if !defined (HAVE_TERMIOS_H) || !defined (HAVE_TCGETATTR) || defined (ultrix)
#  define TERMIOS_MISSING
#endif

#if defined (STRCOLL_BROKEN)
#  define HAVE_STRCOLL 1
#endif

#if defined (__STDC__) && defined (HAVE_STDARG_H)
#  define PREFER_STDARG
#  define USE_VARARGS
#else
#  if defined (HAVE_VARARGS_H)
#    define PREFER_VARARGS
#    define USE_VARARGS
#  endif
#endif
