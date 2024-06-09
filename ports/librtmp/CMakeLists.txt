# Unofficial librtmp CMakeLists.txt from Makefile of https://git.ffmpeg.org/gitweb/rtmpdump.git/blob/6f6bb1353fc84f4cc37138baa99f586750028a01:/librtmp/Makefile
cmake_minimum_required(VERSION 3.29)

project(librtmp
    VERSION ${VERSION}
    DESCRIPTION "RTMP implementation"
    HOMEPAGE_URL "http://rtmpdump.mplayerhq.hu"
    LANGUAGES C
)
set(LIBRTMP_SO_VERSION ${LIBRTMP_SO_VERSION})

# options switch `LIBRTMP_CRYPTO` and string `LIBRTMP_SSL` of "NOSSL;POLARSSL;OPENSSL;GNUTLS"
option(LIBRTMP_CRYPTO "" ON)
if(LIBRTMP_CRYPTO)
    set(LIBRTMP_SSL "OPENSSL" CACHE STRING "")
    set(LIBRTMP_SSL_ITEMS "NOSSL" "POLARSSL" "OPENSSL" "GNUTLS")
    set_property(CACHE LIBRTMP_SSL PROPERTY STRINGS ${LIBRTMP_SSL_ITEMS})
    if(NOT LIBRTMP_SSL IN_LIST LIBRTMP_SSL_ITEMS)
        message(FATAL_ERROR "String option LIBRTMP_SSL must be one of ${LIBRTMP_SSL_ITEMS}")
    endif()
endif()

# target librtmp
set(librtmp_target "librtmp")
add_library(${librtmp_target})
set_target_properties(${librtmp_target} PROPERTIES VERSION ${PROJECT_VERSION} SOVERSION ${LIBRTMP_SO_VERSION})
if(WIN32)
    target_sources(${librtmp_target} PRIVATE "librtmp.def")
endif()

# target librtmp_public
set(librtmp_public "librtmp_public")
add_library(${librtmp_public} INTERFACE)
target_compile_definitions(${librtmp_public} INTERFACE "RTMPDUMP_VERSION=\"${PROJECT_VERSION}\"")

# target librtmp_local
set(librtmp_local "librtmp_local")
add_library(${librtmp_local} INTERFACE)
target_compile_definitions(${librtmp_local} INTERFACE "LIBRTMP_ONLY")

# target librtmp_transitive
set(librtmp_transitive "librtmp_transitive")
add_library(${librtmp_transitive} INTERFACE)

# dependency zlib
find_package(ZLIB REQUIRED)
target_link_libraries(${librtmp_transitive} INTERFACE ZLIB::ZLIB)

# dependency crypto
if(NOT LIBRTMP_CRYPTO)
    target_compile_definitions(${librtmp_public} INTERFACE "NO_CRYPTO")
else()
    if(LIBRTMP_SSL STREQUAL "OPENSSL")
        target_compile_definitions(${librtmp_public} INTERFACE "USE_OPENSSL")
        find_package(OpenSSL CONFIG REQUIRED)
        target_link_libraries(${librtmp_transitive} INTERFACE OpenSSL::SSL OpenSSL::Crypto)
    else()
        message(FATAL_ERROR "Unsupported LIBRTMP_SSL: ${LIBRTMP_SSL}")
    endif()
endif()

# dependency system
if(WIN32)
    target_link_libraries(${librtmp_transitive} INTERFACE ws2_32 winmm)
endif()

# target objects
set(librtmp_obj_list "log" "rtmp" "amf" "hashswf" "parseurl")
add_library(log OBJECT)
target_sources(log PRIVATE "log.c" PUBLIC FILE_SET HEADERS FILES "log.h")
add_library(rtmp OBJECT)
target_sources(rtmp PRIVATE "rtmp.c" PUBLIC FILE_SET HEADERS FILES "rtmp.h" "rtmp_sys.h" "handshake.h" "dh.h" "log.h" "amf.h")
add_library(amf OBJECT)
target_sources(amf PRIVATE "amf.c" PUBLIC FILE_SET HEADERS FILES "amf.h" "bytes.h" "log.h")
add_library(hashswf OBJECT)
target_sources(hashswf PRIVATE "hashswf.c" PUBLIC FILE_SET HEADERS FILES "http.h" "rtmp.h" "rtmp_sys.h")
add_library(parseurl OBJECT)
target_sources(parseurl PRIVATE "parseurl.c" PUBLIC FILE_SET HEADERS FILES "rtmp.h" "rtmp_sys.h" "log.h")

# link
foreach(obj IN LISTS librtmp_obj_list)
    target_link_libraries(${obj} PUBLIC ${librtmp_public} PRIVATE ${librtmp_transitive} $<BUILD_LOCAL_INTERFACE:${librtmp_local}>)
endforeach()
target_link_libraries(${librtmp_target} PUBLIC ${librtmp_obj_list})

# === Install ===

# install settings
include(GNUInstallDirs)
set(librtmp_package_name "unofficial-librtmp")
set(librtmp_namespace "unofficial::librtmp::")
set(librtmp_target_list "${librtmp_target};${librtmp_obj_list};${librtmp_public};${librtmp_transitive}")
set(librtmp_export_targets "librtmp-targets")
set(librtmp_install_include "${CMAKE_INSTALL_INCLUDEDIR}/librtmp")
set(librtmp_install_share "${CMAKE_INSTALL_DATAROOTDIR}/${librtmp_package_name}")
set(librtmp_config_filename "${librtmp_package_name}-config.cmake")
set(librtmp_config_template_path "${CMAKE_CURRENT_BINARY_DIR}/Config.cmake.in")

# install targets
install(TARGETS ${librtmp_target_list}
        EXPORT "${librtmp_export_targets}"
        FILE_SET HEADERS DESTINATION "${librtmp_install_include}"
)

install(EXPORT "${librtmp_export_targets}"
    NAMESPACE "${librtmp_namespace}"
    DESTINATION "${librtmp_install_share}"
)

# generate configs
file(WRITE "${librtmp_config_template_path}"
[[@PACKAGE_INIT@
set(LIBRTMP_CRYPTO @LIBRTMP_CRYPTO@)
set(LIBRTMP_SSL @LIBRTMP_SSL@)
include(CMakeFindDependencyMacro)
find_dependency(ZLIB REQUIRED)
if(LIBRTMP_CRYPTO AND LIBRTMP_SSL STREQUAL "OPENSSL")
    find_dependency(OpenSSL CONFIG REQUIRED)
endif()
include("${CMAKE_CURRENT_LIST_DIR}/@librtmp_export_targets@.cmake")
]]
)
include(CMakePackageConfigHelpers)
configure_package_config_file("${librtmp_config_template_path}"
  "${librtmp_config_filename}"
  INSTALL_DESTINATION "${librtmp_install_share}"
)

# install configs
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${librtmp_config_filename}" DESTINATION "${librtmp_install_share}")

# install man
install(FILES "librtmp.3" "librtmp.3.html" DESTINATION "${CMAKE_INSTALL_MANDIR}/man3")
