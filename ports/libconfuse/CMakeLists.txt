cmake_minimum_required(VERSION 3.14)

set(ac_init_line_re "AC_INIT\\(([^,]+), ([^,]+), ([^,]+), ([^)]+)\\)")
file(STRINGS
    ${CMAKE_CURRENT_LIST_DIR}/configure.ac
    ac_init_line
    REGEX ${ac_init_line_re}
)

string(REGEX REPLACE "${ac_init_line_re}" "\\1" PACKAGE_NAME      ${ac_init_line})
string(REGEX REPLACE "${ac_init_line_re}" "\\2" PACKAGE_VERSION   ${ac_init_line})
string(REGEX REPLACE "${ac_init_line_re}" "\\3" PACKAGE_BUGREPORT ${ac_init_line})
string(REGEX REPLACE "${ac_init_line_re}" "\\4" PACKAGE           ${ac_init_line})

set(PACKAGE_TARNAME ${PACKAGE})
set(PACKAGE_STRING  "${PACKAGE_NAME} ${PACKAGE_VERSION}")

string(REGEX REPLACE "([0-9]+.[0-9]+.[0-9]+).*" "\\1" SEMANTIC_VERSION ${PACKAGE_VERSION})

project(libconfuse VERSION ${SEMANTIC_VERSION} LANGUAGES C)

include(CheckFunctionExists)
include(CheckIncludeFile)
include(GNUInstallDirs)

find_package(FLEX REQUIRED)
find_package(Gettext QUIET)
find_package(Intl QUIET)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

if (GETTEXT_FOUND)
    set(ENABLE_NLS 1)
endif ()

# libconfig.pc.in
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${prefix})
set(libdir ${prefix}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${prefix}/${CMAKE_INSTALL_INCLUDEDIR})
set(VERSION ${PROJECT_VERSION})

if (Intl_FOUND AND Intl_LIBRARIES)
    set(LTLIBINTL ${Intl_LIBRARIES})
endif ()

configure_file(libconfuse.pc.in ${CMAKE_CURRENT_BINARY_DIR}/libconfuse.pc @ONLY)

check_function_exists(dcgettext  HAVE_DCGETTEXT)
check_function_exists(fmemopen   HAVE_FMEMOPEN)
check_function_exists(funopen    HAVE_FUNOPEN)
check_function_exists(gettext    HAVE_GETTEXT)
check_function_exists(iconv      HAVE_ICONV)
check_function_exists(strcasecmp HAVE_STRCASECMP)
check_function_exists(strdup     HAVE_STRDUP)
check_function_exists(_strdup    HAVE__STRDUP)
check_function_exists(strndup    HAVE_STRNDUP)
check_function_exists(setenv     HAVE_SETENV)
check_function_exists(unsetenv   HAVE_UNSETENV)
check_function_exists(_putenv    HAVE__PUTENV)

if (MSVC)
    check_function_exists(_fileno  HAVE__FILENO)
    check_function_exists(_isatty  HAVE__ISATTY)
    check_function_exists(_stricmp HAVE_STRCASECMP)
endif ()

check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(string.h HAVE_STRING_H)

check_include_file(strings.h   HAVE_STRINGS_H)
check_include_file(sys/stat.h  HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h    HAVE_UNISTD_H)
check_include_file(windows.h   HAVE_WINDOWS_H)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

flex_target(
    CONFUSE
    src/lexer.l 
    ${CMAKE_CURRENT_BINARY_DIR}/lexer.c
    COMPILE_FLAGS -Pcfg_yy
)

set(libconfuse_sources
    src/confuse.c
    ${FLEX_CONFUSE_OUTPUTS}
)

if (NOT HAVE_FMEMOPEN)
    list(APPEND libconfuse_sources src/fmemopen.c)
endif ()

add_library(libconfuse ${libconfuse_sources})

if (BUILD_SHARED_LIBS)
    if (WIN32)
        target_compile_definitions(libconfuse PRIVATE BUILDING_DLL)
    endif ()
else ()
    target_compile_definitions(libconfuse PUBLIC BUILDING_STATIC)
endif ()

string(COMPARE EQUAL "${CMAKE_C_COMPILER_ID}" "GNU" USING_GNUC)

target_compile_definitions(libconfuse
    PUBLIC
        $<BUILD_INTERFACE:HAVE_CONFIG_H>
    PRIVATE
        $<$<BOOL:${MSVC}>:_CRT_SECURE_NO_WARNINGS>
        $<$<BOOL:${MSVC}>:_CRT_NONSTDC_NO_DEPRECATE>
        $<$<BOOL:${MSVC}>:strcasecmp=_stricmp>
        $<$<BOOL:${USING_GNUC}>:_GNU_SOURCE>
)

target_include_directories(libconfuse
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(libconfuse PROPERTIES PUBLIC_HEADER src/confuse.h)

install(TARGETS libconfuse EXPORT unofficial-libconfuse-config)

install(
    EXPORT unofficial-libconfuse-config
    NAMESPACE unofficial::libconfuse::
    DESTINATION share/unofficial-libconfuse
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libconfuse.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
