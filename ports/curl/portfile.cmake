include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF curl-7_55_1
    SHA512 b5c6dd6cca8d07c08d1760feff9822f1264359adde068afd1584fc3fdcfa50c68e0e1b5ecaa277298ad0923b61019943c181ee1f0870c312399038c4c4e0e327
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002_fix_uwp.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    SET(CURL_STATICLIB OFF)
else()
    SET(CURL_STATICLIB ON)
endif()

set(UWP_OPTIONS)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(UWP_OPTIONS
        -DUSE_WIN32_LDAP=OFF
        -DCURL_DISABLE_TELNET=ON
        -DENABLE_IPV6=OFF
        -DENABLE_UNIX_SOCKETS=OFF
    )
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${UWP_OPTIONS}
        -DBUILD_TESTING=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
        -DCMAKE_USE_OPENSSL=ON
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    # Drop debug suffix, as FindCURL.cmake does not look for it
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libcurl_imp.lib ${CURRENT_PACKAGES_DIR}/lib/libcurl.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d_imp.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

file(READ ${CURRENT_PACKAGES_DIR}/include/curl/curl.h CURL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef CURL_STATICLIB" "#if 1" CURL_H "${CURL_H}")
else()
    string(REPLACE "#ifdef CURL_STATICLIB" "#if 0" CURL_H "${CURL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/curl/curl.h "${CURL_H}")

vcpkg_copy_pdbs()
