cmake_minimum_required(VERSION 3.0)
project(libexif LANGUAGES C)

set(PACKAGE "libexif")

option(ENABLE_NLS "Enable NLS" OFF)

set(HEADERS
    libexif/_stdint.h
    libexif/exif.h
    libexif/exif-byte-order.h
    libexif/exif-content.h
    libexif/exif-data.h
    libexif/exif-data-type.h
    libexif/exif-entry.h
    libexif/exif-format.h
    libexif/exif-gps-ifd.h
    libexif/exif-ifd.h
    libexif/exif-loader.h
    libexif/exif-log.h
    libexif/exif-mem.h
    libexif/exif-mnote-data.h
    libexif/exif-mnote-data-priv.h
    libexif/exif-system.h
    libexif/exif-tag.h
    libexif/exif-utils.h
)

set(SOURCES
    libexif/exif-byte-order.c
    libexif/exif-content.c
    libexif/exif-data.c
    libexif/exif-entry.c
    libexif/exif-format.c
    libexif/exif-gps-ifd.c
    libexif/exif-ifd.c
    libexif/exif-loader.c
    libexif/exif-log.c
    libexif/exif-mem.c
    libexif/exif-mnote-data.c
    libexif/exif-tag.c
    libexif/exif-utils.c
)

set(HEADERS_APPLE
    libexif/apple/exif-mnote-data-apple.h
    libexif/apple/mnote-apple-entry.h
    libexif/apple/mnote-apple-tag.h
)

set(SOURCES_APPLE
    libexif/apple/exif-mnote-data-apple.c
    libexif/apple/mnote-apple-entry.c
    libexif/apple/mnote-apple-tag.c
)

set(HEADERS_CANON
    libexif/canon/exif-mnote-data-canon.h
    libexif/canon/mnote-canon-entry.h
    libexif/canon/mnote-canon-tag.h
)

set(SOURCES_CANON
    libexif/canon/exif-mnote-data-canon.c
    libexif/canon/mnote-canon-entry.c
    libexif/canon/mnote-canon-tag.c
)

set(HEADERS_FUJI
    libexif/fuji/exif-mnote-data-fuji.h
    libexif/fuji/mnote-fuji-entry.h
    libexif/fuji/mnote-fuji-tag.h
)

set(SOURCES_FUJI
    libexif/fuji/exif-mnote-data-fuji.c
    libexif/fuji/mnote-fuji-entry.c
    libexif/fuji/mnote-fuji-tag.c
)

set(HEADERS_OLYMPUS
    libexif/olympus/exif-mnote-data-olympus.h
    libexif/olympus/mnote-olympus-entry.h
    libexif/olympus/mnote-olympus-tag.h
)

set(SOURCES_OLYMPUS
    libexif/olympus/exif-mnote-data-olympus.c
    libexif/olympus/mnote-olympus-entry.c
    libexif/olympus/mnote-olympus-tag.c
)

set(HEADERS_PENTAX
    libexif/pentax/exif-mnote-data-pentax.h
    libexif/pentax/mnote-pentax-entry.h
    libexif/pentax/mnote-pentax-tag.h
)

set(SOURCES_PENTAX
    libexif/pentax/exif-mnote-data-pentax.c
    libexif/pentax/mnote-pentax-entry.c
    libexif/pentax/mnote-pentax-tag.c
)

if(MSVC)
    set(SOURCES_MSVC "libexif.def")
endif()

add_library(libexif
    ${SOURCES} 
    ${SOURCES_APPLE}
    ${SOURCES_CANON} 
    ${SOURCES_FUJI} 
    ${SOURCES_OLYMPUS}
    ${SOURCES_PENTAX}
    ${SOURCES_MSVC}
)

target_include_directories(libexif PRIVATE .)
target_include_directories(libexif PRIVATE ${CMAKE_BINARY_DIR})
target_compile_definitions(libexif PRIVATE -D_CRT_SECURE_NO_WARNINGS)
target_compile_definitions(libexif PRIVATE -DGETTEXT_PACKAGE="${PACKAGE}")

include(CheckFunctionExists)
include(CheckIncludeFile)

check_function_exists(dcgettext HAVE_DCGETTEXT)
check_function_exists(gettext HAVE_DCGETTEXT)
check_function_exists(iconv HAVE_DCGETTEXT)
check_function_exists(localtime_r HAVE_DCGETTEXT)

check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)

configure_file(config.h.cmake config.h)

install(
    TARGETS libexif
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(FILES ${HEADERS}         DESTINATION include/libexif)
install(FILES ${HEADERS_APPLE}   DESTINATION include/libexif/apple)
install(FILES ${HEADERS_CANON}   DESTINATION include/libexif/canon)
install(FILES ${HEADERS_FUJI}    DESTINATION include/libexif/fuji)
install(FILES ${HEADERS_OLYMPUS} DESTINATION include/libexif/olympus)
install(FILES ${HEADERS_PENTAX}  DESTINATION include/libexif/pentax)
