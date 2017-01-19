
#define FC_CACHEDIR "./"

/* The normal alignment of `double', in bytes. */
#define ALIGNOF_DOUBLE 8

/* Use libxml2 instead of Expat */
/* #undef ENABLE_LIBXML2 */

/* Additional font directories */
#define FC_ADD_FONTS "yes"

/* Architecture prefix to use for cache file names */
/* #undef FC_ARCHITECTURE */

/* System font directory */
#define FC_DEFAULT_FONTS "c:/windows/fonts"

/* Define to nothing if C supports flexible array members, and to 1 if it does
   not. That way, with a declaration like `struct s { int n; double
   d[FLEXIBLE_ARRAY_MEMBER]; };', the struct hack can be used with pre-C99
   compilers. When computing the size of such an object, don't use 'sizeof
   (struct s)' as it overestimates the size. Use 'offsetof (struct s, d)'
   instead. Don't use 'offsetof (struct s, d[0])', as this doesn't work with
   MSVC and with C++ compilers. */
#define FLEXIBLE_ARRAY_MEMBER /**/

/* Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
   */
#define HAVE_DIRENT_H 1

/* Define to 1 if you have the <dlfcn.h> header file. */
/* #undef HAVE_DLFCN_H */

/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
/* #undef HAVE_DOPRNT */

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have the `fstatfs' function. */
/* #undef HAVE_FSTATFS */

/* Define to 1 if you have the `fstatvfs' function. */
/* #undef HAVE_FSTATVFS */

/* FT_Bitmap_Size structure includes y_ppem field */
#define HAVE_FT_BITMAP_SIZE_Y_PPEM 1

/* Define to 1 if you have the `FT_Get_BDF_Property' function. */
#define HAVE_FT_GET_BDF_PROPERTY 1

/* Define to 1 if you have the `FT_Get_Next_Char' function. */
#define HAVE_FT_GET_NEXT_CHAR 1

/* Define to 1 if you have the `FT_Get_PS_Font_Info' function. */
#define HAVE_FT_GET_PS_FONT_INFO 1

/* Define to 1 if you have the `FT_Get_X11_Font_Format' function. */
#define HAVE_FT_GET_X11_FONT_FORMAT 1

/* Define to 1 if you have the `FT_Has_PS_Glyph_Names' function. */
#define HAVE_FT_HAS_PS_GLYPH_NAMES 1

/* Define to 1 if you have the `FT_Select_Size' function. */
#define HAVE_FT_SELECT_SIZE 1

/* Define to 1 if you have the `getexecname' function. */
/* #undef HAVE_GETEXECNAME */

/* Define to 1 if you have the `getopt' function. */
#define HAVE_GETOPT 1

/* Define to 1 if you have the `getopt_long' function. */
#define HAVE_GETOPT_LONG 1

/* Define to 1 if you have the `getpagesize' function. */
#define HAVE_GETPAGESIZE 1

/* Define to 1 if you have the `getprogname' function. */
/* #undef HAVE_GETPROGNAME */

/* Have Intel __sync_* atomic primitives */
#define HAVE_INTEL_ATOMIC_PRIMITIVES 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `link' function. */
/* #undef HAVE_LINK */

/* Define to 1 if you have the `lrand48' function. */
/* #undef HAVE_LRAND48 */

/* Define to 1 if you have the `lstat' function. */
/* #undef HAVE_LSTAT */

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the `mkdtemp' function. */
/* #undef HAVE_MKDTEMP */

/* Define to 1 if you have the `mkostemp' function. */
/* #undef HAVE_MKOSTEMP */

/* Define to 1 if you have the `mkstemp' function. */
/* #undef HAVE_MKSTEMP */

/* Define to 1 if you have a working `mmap' system call. */
/* #undef HAVE_MMAP */

/* Define to 1 if you have the <ndir.h> header file, and it defines `DIR'. */
/* #undef HAVE_NDIR_H */

/* Define to 1 if you have the 'posix_fadvise' function. */
/* #undef HAVE_POSIX_FADVISE */

/* Have POSIX threads */
/* #undef HAVE_PTHREAD */

/* Have PTHREAD_PRIO_INHERIT. */
/* #undef HAVE_PTHREAD_PRIO_INHERIT */

/* Define to 1 if you have the `rand' function. */
#define HAVE_RAND 1

/* Define to 1 if you have the `random' function. */
/* #undef HAVE_RANDOM */

/* Define to 1 if you have the `random_r' function. */
/* #undef HAVE_RANDOM_R */

/* Define to 1 if you have the `rand_r' function. */
/* #undef HAVE_RAND_R */

/* Define to 1 if you have the `readlink' function. */
/* #undef HAVE_READLINK */

/* Define to 1 if you have the 'scandir' function. */
/* #undef HAVE_SCANDIR */

/* Define to 1 if you have the 'scandir' function with int (* compar)(const
   void *, const void *) */
/* #undef HAVE_SCANDIR_VOID_P */

/* Define to 1 if you have the <sched.h> header file. */
/* #undef HAVE_SCHED_H */

/* Have sched_yield */
/* #undef HAVE_SCHED_YIELD */

/* Have Solaris __machine_*_barrier and atomic_* operations */
/* #undef HAVE_SOLARIS_ATOMIC_OPS */

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
/* #undef HAVE_STRINGS_H */

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if `d_type' is a member of `struct dirent'. */
/* #undef HAVE_STRUCT_DIRENT_D_TYPE */

/* Define to 1 if `st_mtim' is a member of `struct stat'. */
/* #undef HAVE_STRUCT_STAT_ST_MTIM */

/* Define to 1 if `f_flags' is a member of `struct statfs'. */
/* #undef HAVE_STRUCT_STATFS_F_FLAGS */

/* Define to 1 if `f_fstypename' is a member of `struct statfs'. */
/* #undef HAVE_STRUCT_STATFS_F_FSTYPENAME */

/* Define to 1 if `f_basetype' is a member of `struct statvfs'. */
/* #undef HAVE_STRUCT_STATVFS_F_BASETYPE */

/* Define to 1 if `f_fstypename' is a member of `struct statvfs'. */
/* #undef HAVE_STRUCT_STATVFS_F_FSTYPENAME */

/* Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_DIR_H */

/* Define to 1 if you have the <sys/mount.h> header file. */
/* #undef HAVE_SYS_MOUNT_H */

/* Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_NDIR_H */

/* Define to 1 if you have the <sys/param.h> header file. */
/* #undef HAVE_SYS_PARAM_H */

/* Define to 1 if you have the <sys/statfs.h> header file. */
/* #undef HAVE_SYS_STATFS_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/vfs.h> header file. */
/* #undef HAVE_SYS_VFS_H */

/* Define to 1 if `usLowerOpticalPointSize' is a member of `TT_OS2'. */
/* #undef HAVE_TT_OS2_USLOWEROPTICALPOINTSIZE */

/* Define to 1 if `usUpperOpticalPointSize' is a member of `TT_OS2'. */
/* #undef HAVE_TT_OS2_USUPPEROPTICALPOINTSIZE */

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the `vprintf' function. */
#define HAVE_VPRINTF 1

/* Can use #warning in C files */
#define HAVE_WARNING_CPP_DIRECTIVE 1

/* Use xmlparse.h instead of expat.h */
/* #undef HAVE_XMLPARSE_H */

/* Define to 1 if you have the `XML_SetDoctypeDeclHandler' function. */
#define HAVE_XML_SETDOCTYPEDECLHANDLER 1

/* Define to 1 if you have the `_mktemp_s' function. */
#define HAVE__MKTEMP_S 1

/* Define to necessary symbol if this constant
 uses a non-standard name on
   your system. */
/* #undef PTHREAD_CREATE_JOINABLE */

/* The size of `char', as computed by sizeof. */
#define SIZEOF_CHAR 1

/* The size of `int', as computed by sizeof. */
#define SIZEOF_INT 4

/* The size of `long', as computed by sizeof. */
#define SIZEOF_LONG 4

/* The size of `short', as computed by sizeof. */
#define SIZEOF_SHORT 2

/* The size of `void*', as computed by sizeof. */
/* The size of `void *', as computed by sizeof. */
#if defined(_WIN64)
#define SIZEOF_VOIDP 8
#define SIZEOF_VOID_P 8
#else
#define SIZEOF_VOIDP 4
#define SIZEOF_VOID_P 4
#endif

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Use iconv. */
#define USE_ICONV 1