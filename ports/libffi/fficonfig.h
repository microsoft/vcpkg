#ifdef __linux__
#define EH_FRAME_FLAGS "a"
#endif
#define HAVE_ALLOCA 1
#ifndef _WIN64
#define HAVE_AS_ASCII_PSEUDO_OP 1
#endif
#ifndef _WIN64
#define HAVE_AS_STRING_PSEUDO_OP 1
#endif
#ifndef _WIN64
#define HAVE_AS_X86_PCREL 1
#endif
#ifdef __linux__
#define HAVE_HIDDEN_VISIBILITY_ATTRIBUTE 1
#endif
#define HAVE_INTTYPES_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define LT_OBJDIR ".libs/"
#define PACKAGE "libffi"
#define PACKAGE_BUGREPORT "http://github.com/libffi/libffi/issues"
#define PACKAGE_NAME "libffi"
#define PACKAGE_STRING "libffi 3.4.2"
#define PACKAGE_TARNAME "libffi"
#define PACKAGE_URL ""
#define PACKAGE_VERSION "3.4.2"
#define SIZEOF_DOUBLE 8
#define SIZEOF_LONG_DOUBLE 8
#ifndef _WIN64
#define SIZEOF_SIZE_T 4
#else
#define SIZEOF_SIZE_T 8
#endif
#define STDC_HEADERS 1
#ifndef __linux__
#ifndef _WIN64
#define SYMBOL_UNDERSCORE 1
#endif
#endif
#define VERSION "3.4.2"
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#endif

#ifdef HAVE_HIDDEN_VISIBILITY_ATTRIBUTE
#ifdef LIBFFI_ASM
#define FFI_HIDDEN(name) .hidden name
#else
#define FFI_HIDDEN __attribute__ ((visibility ("hidden")))
#endif
#else
#ifdef LIBFFI_ASM
#define FFI_HIDDEN(name)
#else
#define FFI_HIDDEN
#endif
#endif

