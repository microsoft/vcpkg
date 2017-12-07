cmake_minimum_required(VERSION 3.8)

project(gmime C)

set(GLIB_LIB_SUFFIX 2.0)
set(GMIME_DLL_SUFFIX 3)
set(GMIME_LIB_SUFFIX 3.0)

# Find glib
find_path(GLIB_INCLUDE_DIR glib.h)
find_library(GLIB_GLIB_LIBRARY glib-${GLIB_LIB_SUFFIX})
find_library(GLIB_GIO_LIBRARY gio-${GLIB_LIB_SUFFIX})
find_library(GLIB_GOBJECT_LIBRARY gobject-${GLIB_LIB_SUFFIX})
set(GLIB_LIBRARIES ${GLIB_GLIB_LIBRARY} ${GLIB_GIO_LIBRARY} ${GLIB_GOBJECT_LIBRARY})

# Find other deps
find_path(ICONV_INCLUDE_DIR iconv.h)
find_library(ICONV_LIBRARY NAMES iconv libiconv)

find_library(IDN_LIBRARY NAMES libidn2 libidn)

find_package(zlib REQUIRED)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

add_definitions(-DHAVE_CONFIG_H)
add_definitions(-DG_LOG_DOMAIN="GMime")

# List the source files
set(LIB_SRC gmime/gmime.c
            gmime/gmime-application-pkcs7-mime.c
            gmime/gmime-autocrypt.c
            gmime/gmime-certificate.c
            gmime/gmime-charset.c
            gmime/gmime-common.c
            gmime/gmime-content-type.c
            gmime/gmime-crypto-context.c
            gmime/gmime-data-wrapper.c
            gmime/gmime-disposition.c
            gmime/gmime-encodings.c
            gmime/gmime-events.c
            gmime/gmime-filter.c
            gmime/gmime-filter-basic.c
            gmime/gmime-filter-best.c
            gmime/gmime-filter-charset.c
            gmime/gmime-filter-checksum.c
            gmime/gmime-filter-dos2unix.c
            gmime/gmime-filter-enriched.c
            gmime/gmime-filter-from.c
            gmime/gmime-filter-gzip.c
            gmime/gmime-filter-html.c
            gmime/gmime-filter-smtp-data.c
            gmime/gmime-filter-strip.c
            gmime/gmime-filter-unix2dos.c
            gmime/gmime-filter-windows.c
            gmime/gmime-filter-yenc.c
            gmime/gmime-format-options.c
            gmime/gmime-gpg-context.c
            gmime/gmime-gpgme-utils.c
            gmime/gmime-header.c
            gmime/gmime-iconv.c
            gmime/gmime-iconv-utils.c
            gmime/gmime-message.c
            gmime/gmime-message-part.c
            gmime/gmime-message-partial.c
            gmime/gmime-multipart.c
            gmime/gmime-multipart-encrypted.c
            gmime/gmime-multipart-signed.c
            gmime/gmime-object.c
            gmime/gmime-param.c
            gmime/gmime-parse-utils.c
            gmime/gmime-parser.c
            gmime/gmime-parser-options.c
            gmime/gmime-part.c
            gmime/gmime-part-iter.c
            gmime/gmime-pkcs7-context.c
            gmime/gmime-references.c
            gmime/gmime-signature.c
            gmime/gmime-stream.c
            gmime/gmime-stream-buffer.c
            gmime/gmime-stream-cat.c
            gmime/gmime-stream-file.c
            gmime/gmime-stream-filter.c
            gmime/gmime-stream-fs.c
            gmime/gmime-stream-gio.c
            gmime/gmime-stream-mem.c
            gmime/gmime-stream-mmap.c
            gmime/gmime-stream-null.c
            gmime/gmime-stream-pipe.c
            gmime/gmime-text-part.c
            gmime/gmime-utils.c
            gmime/internet-address.c
            util/packed.c
            util/url-scanner.c
            util/gtrie.c
)

file(GLOB LIB_HEADERS gmime/gmime-*.h)
list(APPEND LIB_HEADERS gmime/gmime.h)
list(APPEND LIB_HEADERS gmime/internet-address.h)

if(MSVC AND BUILD_SHARED_LIBS)
    set(MSVC_SRC gmime.def)
endif()

add_library(${PROJECT_NAME} ${LIB_SRC} ${MSVC_SRC})

set_target_properties(${PROJECT_NAME} PROPERTIES 
    OUTPUT_NAME ${PROJECT_NAME}-${GMIME_DLL_SUFFIX}
    ARCHIVE_OUTPUT_NAME ${PROJECT_NAME}-${GMIME_LIB_SUFFIX}
)

target_include_directories(${PROJECT_NAME} PRIVATE . ./util ${GLIB_INCLUDE_DIR} ${ICONV_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${GLIB_LIBRARIES} ${ICONV_LIBRARY} ${ZLIB_LIBRARIES} ${IDN_LIBRARY})
target_link_libraries(${PROJECT_NAME} PRIVATE Ws2_32.lib)

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES ${LIB_HEADERS} DESTINATION include/gmime)
