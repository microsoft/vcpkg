cmake_minimum_required(VERSION 3.0)
project(fontconfig)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS)
add_definitions(-FI${FC_INCLUDE_DIR}/config.h)

if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(LIB_SUFFIX d)
endif()

# find dependencies
find_path(ICONV_INCLUDE_DIR iconv.h)
find_library(ICONV_LIBRARY NAMES iconv libiconv)
find_path(FREETYPE_INCLUDE_DIR ft2build.h)
find_library(FREETYPE_LIBRARY freetype${LIB_SUFFIX})
find_path(EXPAT_INCLUDE_DIR expat.h)
find_library(EXPAT_LIBRARY expat)

add_library(fontconfig
    src/fcatomic.c
    src/fcblanks.c
    src/fccache.c
    src/fccfg.c
    src/fccharset.c
    src/fccompat.c
    src/fcdbg.c
    src/fcdefault.c
    src/fcdir.c
    src/fcformat.c
    src/fcfreetype.c
    src/fcfs.c
    src/fcinit.c
    src/fclang.c
    src/fclist.c
    src/fcmatch.c
    src/fcmatrix.c
    src/fcname.c
    src/fcobjs.c
    src/fcpat.c
    src/fcrange.c
    src/fcserialize.c
    src/fcstat.c
    src/fcstr.c
    src/fcweight.c
    src/fcxml.c
    src/ftglue.c)

target_include_directories(fontconfig PRIVATE .
    ${FC_INCLUDE_DIR}
    ${FREETYPE_INCLUDE_DIR}
    ${EXPAT_INCLUDE_DIR}
    ${ICONV_INCLUDE_DIR})

target_link_libraries(fontconfig
    ${FREETYPE_LIBRARY}
    ${ICONV_LIBRARY}
    ${EXPAT_LIBRARY})

install(TARGETS fontconfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

if(NOT FC_SKIP_HEADERS)
    install(FILES
        fontconfig/fontconfig.h
        fontconfig/fcfreetype.h
        fontconfig/fcprivate.h
        DESTINATION include/fontconfig)
endif()

if(NOT FC_SKIP_TOOLS)
    set(FC_DEFAULT_FONTS WINDOWSFONTDIR)
    set(FC_FONTPATH)
    set(FC_CACHEDIR WINDOWSTEMPDIR_FONTCONFIG_CACHE)
    set(CONFIGDIR ./fonts/conf.d)
    configure_file(fonts.conf.in ${CMAKE_SOURCE_DIR}/fonts.conf @ONLY)
    install(FILES fonts.conf DESTINATION tools/fontconfig/fonts)
    install(DIRECTORY conf.d DESTINATION tools/fontconfig/fonts FILES_MATCHING PATTERN "*.conf")
endif()
