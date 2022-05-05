cmake_minimum_required(VERSION 3.8)

project(libidn2 C)

find_package(Iconv REQUIRED)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

add_definitions(-DIDN2_BUILDING)

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DIDN2_STATIC)
endif()

# List the source files
set(LIB_SRC lib/bidi.c
            lib/context.c
            lib/data.c
            lib/decode.c
            lib/error.c
            lib/free.c
            lib/idna.c
            lib/lookup.c
            lib/puny_decode.c
            lib/puny_encode.c
            lib/register.c
            lib/tables.c
            lib/tr46map.c
            lib/tr46map_data.c
            lib/version.c
)

# List the libunistring source files
set(UNISTR_SRC unistring/c-ctype.c
               unistring/c-strcasecmp.c
               unistring/c-strncasecmp.c
               unistring/free.c
               unistring/striconveh.c
               unistring/striconveha.c
               unistring/uniconv/u8-conv-from-enc.c
               unistring/uniconv/u8-strconv-from-enc.c
               unistring/uniconv/u8-strconv-from-locale.c
               unistring/uniconv/u8-strconv-to-enc.c
               unistring/uniconv/u8-strconv-to-locale.c
               unistring/unistr/u32-cmp.c
               unistring/unistr/u32-cpy.c
               unistring/unistr/u32-cpy-alloc.c
               unistring/unistr/u32-mbtouc-unsafe.c
               unistring/unistr/u32-strlen.c
               unistring/unistr/u32-to-u8.c
               unistring/unistr/u32-uctomb.c
               unistring/unistr/u8-check.c
               unistring/unistr/u8-mblen.c
               unistring/unistr/u8-mbtouc.c
               unistring/unistr/u8-mbtouc-aux.c
               unistring/unistr/u8-mbtouc-unsafe.c
               unistring/unistr/u8-mbtouc-unsafe-aux.c
               unistring/unistr/u8-mbtoucr.c
               unistring/unistr/u8-prev.c
               unistring/unistr/u8-strlen.c
               unistring/unistr/u8-to-u32.c
               unistring/unistr/u8-uctomb.c
               unistring/unistr/u8-uctomb-aux.c
               unistring/uninorm/canonical-decomposition.c
               unistring/uninorm/composition.c
               unistring/uninorm/decompose-internal.c
               unistring/uninorm/decomposition-table.c
               unistring/uninorm/nfc.c
               unistring/uninorm/nfd.c
               unistring/uninorm/u32-normalize.c
               unistring/unictype/bidi_of.c
               unistring/unictype/categ_M.c
               unistring/unictype/categ_none.c
               unistring/unictype/categ_of.c
               unistring/unictype/categ_test.c
               unistring/unictype/combiningclass.c
               unistring/unictype/joiningtype_of.c
               unistring/unictype/scripts.c
)

# List the gnulib source files
set(GL_SRC gl/rawmemchr.c
           gl/strchrnul.c
           gl/strverscmp.c
           gl/msvc-inval.c
           gl/msvc-nothrow.c
           gl/malloca.c
)

add_library(libidn2 ${LIB_SRC} ${UNISTR_SRC} ${GL_SRC})
set_target_properties(libidn2
    PROPERTIES
        OUTPUT_NAME idn2
        PREFIX lib
        IMPORT_PREFIX lib
)

target_include_directories(libidn2 PRIVATE . ./unistring ./gl)
target_link_libraries(libidn2 PRIVATE Iconv::Iconv)

install(TARGETS libidn2
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES lib/idn2.h DESTINATION include)

# Install pc file
set(prefix      "\${pcfiledir}/../..")
set(exec_prefix "\${prefix}")
set(includedir  "\${prefix}/include")
set(libdir      "\${prefix}/lib")
set(LTLIBICONV  "-liconv -lcharset")
set(LTLIBUNISTRING "")
configure_file("libidn2.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/libidn2.pc" @ONLY)
if(WIN32 AND NOT MINGW)
    file(READ "${CMAKE_CURRENT_BINARY_DIR}/libidn2.pc" pc_data)
    string(REPLACE " -lidn" " -llibidn" pc_data "${pc_data}")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libidn2.pc" "${pc_data}")
endif()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/libidn2.pc" DESTINATION "lib/pkgconfig")
