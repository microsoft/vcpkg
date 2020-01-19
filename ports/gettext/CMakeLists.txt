cmake_minimum_required(VERSION 3.5)
project(libintl C)

find_package(unofficial-iconv REQUIRED)

set(CMAKE_STATIC_LIBRARY_PREFIX)
set(CMAKE_SHARED_LIBRARY_PREFIX)

if(WIN32)
    set(HAVE_POSIX_PRINTF 0)
    set(HAVE_SNPRINTF 0)
    set(HAVE_ASPRINTF 0)
    set(HAVE_WPRINTF 0)
    set(HAVE_NEWLOCALE 0)

    configure_file(intl/libgnuintl.win32.h config/libgnuintl.h COPYONLY)
    configure_file(config.win32.h config/config.h COPYONLY)
else()
    set(HAVE_POSIX_PRINTF 1)
    set(HAVE_SNPRINTF 1)
    set(HAVE_ASPRINTF 1)
    set(HAVE_WPRINTF 1)
    set(HAVE_NEWLOCALE 1)
    add_definitions(-DHAVE_NEWLOCALE=1)
    add_definitions(-DHAVE_NEWLOCALE=1)

    set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
    set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    find_package(Threads REQUIRED)
    if(NOT CMAKE_USE_PTHREADS_INIT)
        message(FATAL_ERROR "Error: Only pthreads is currently supported.")
    endif()

    include(CheckFunctionExists)
    include(CheckIncludeFiles)

    if(APPLE)
        set(HAVE_CFLOCALECOPYCURRENT 1)
        set(HAVE_CFPREFERENCESCOPYAPPVALUE 1)
    endif()
    check_function_exists(dcgettext HAVE_DCGETTEXT)
    check_include_files(features.h HAVE_FEATURES_H)
    check_function_exists(gettext HAVE_GETTEXT)
    check_include_files(mach-o/dyld.h HAVE_MACH_O_DYLD_H)
    check_function_exists(mempcpy HAVE_MEMPCPY)
    check_include_files(xlocale.h HAVE_XLOCALE_H)

    configure_file(intl/libgnuintl.in.h config/libgnuintl.h @ONLY)
    configure_file(config.unix.h.in config/config.h @ONLY)
endif()

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/config/libgnuintl.h" DESTINATION include RENAME libintl.h)
endif()

file(READ "${CMAKE_CURRENT_BINARY_DIR}/config/config.h" _contents)
if(NOT WIN32)
    string(REPLACE "/* #undef HAVE_STPCPY */" "#define HAVE_STPCPY 1" _contents "${_contents}")
endif()
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/config/config.h" "${_contents}")

FILE(GLOB SOURCES
    "intl/bindtextdom.c"
    "intl/dcgettext.c"
    "intl/dcigettext.c"
    "intl/dcngettext.c"
    "intl/dgettext.c"
    "intl/dngettext.c"
    "intl/explodename.c"
    "intl/finddomain.c"
    "intl/gettext.c"
    "intl/hash-string.c"
    "intl/intl-compat.c"
    "intl/l10nflist.c"
    "intl/langprefs.c"
    "intl/loadmsgcat.c"
    "intl/localealias.c"
    "intl/localename.c"
    "intl/lock.c"
    "intl/log.c"
    "intl/ngettext.c"
    "intl/osdep.c"
    "intl/plural-exp.c"
    "intl/plural.c"
    "intl/printf.c"
    "intl/relocatable.c"
    "intl/textdomain.c"
    "intl/version.c"
)
if(NOT WIN32)
    list(APPEND SOURCES "intl/setlocale.c")
endif()

set(LOCALDIR "c:/gettext")

add_definitions(-DLOCALEDIR=\"${LOCALDIR}\")
add_definitions(-DLOCALE_ALIAS_PATH=\"${LOCALDIR}\")
add_definitions(-DLIBDIR=\"${LOCALDIR}\")
add_definitions(-DINSTALLDIR=\"${LOCALDIR}\")
if(BUILD_SHARED_LIBS)
  add_definitions(-DBUILDING_DLL)
endif()
add_definitions("-DBUILDING_LIBINTL -DIN_LIBINTL -DENABLE_RELOCATABLE=1 -DIN_LIBRARY")

add_definitions("-DNO_XMALLOC -Dset_relocation_prefix=libintl_set_relocation_prefix -Drelocate=libintl_relocate -DDEPENDS_ON_LIBICONV=1 -DHAVE_CONFIG_H -DHAVE_ICONV -DHAVE_ICONV_H -DICONV_CONST=const -D_CRT_SECURE_NO_WARNINGS")

add_library(libintl ${SOURCES})
target_link_libraries(libintl PRIVATE unofficial::iconv::libcharset unofficial::iconv::libiconv)

target_include_directories(libintl PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/config>
    $<INSTALL_INTERFACE:include>
)

if(APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation REQUIRED)
    target_link_libraries(libintl PRIVATE ${COREFOUNDATION_LIBRARY})
endif()
if(NOT WIN32)
    target_link_libraries(libintl PRIVATE Threads::Threads)
endif()
if (WIN32)
    target_link_libraries(libintl PRIVATE Advapi32.lib)
endif()

install(TARGETS libintl
  EXPORT unofficial-gettext-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION bin
  ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-gettext-targets
    FILE unofficial-gettext-targets.cmake
    NAMESPACE unofficial::gettext::
    DESTINATION share/unofficial-gettext
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-gettext-config.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-iconv)
find_dependency(Threads)
include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-gettext-targets.cmake)
")

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-gettext-config.cmake
    DESTINATION share/unofficial-gettext
)
