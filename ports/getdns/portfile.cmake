vcpkg_fail_port_install(ON_TARGET "uwp")

set(GETDNS_VERSION 1.6.0)
set(GETDNS_HASH 4d3a67cd76e7ce53a31c9b92607d7768381a1f916e7950fe4e69368fa585d38dbfc04975630fbe8d8bd14f4bebf83a3516e063b5b54e0922548edc0952ee7b4e)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GETDNS_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" GETDNS_ENABLE_SHARED)

vcpkg_download_distfile(ARCHIVE
    URLS "https://getdnsapi.net/dist/getdns-${GETDNS_VERSION}.tar.gz"
    FILENAME "getdns-${GETDNS_VERSION}.tar.gz"
    SHA512 ${GETDNS_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GETDNS_VERSION}
    PATCHES
        "openssl_depend_libs.patch"
        "ignore_copying.patch"
        "install_dlls.patch"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    libevent BUILD_LIBEVENT2
    libuv BUILD_LIBUV
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_GETDNS_QUERY=OFF
        -DBUILD_GETDNS_SERVER_MON=OFF
        -DENABLE_STATIC=${GETDNS_ENABLE_STATIC}
        -DENABLE_SHARED=${GETDNS_ENABLE_SHARED}
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
