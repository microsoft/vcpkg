vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getdnsapi/getdns
    REF  1b3f57079297f7dead1723f0f6d567e77ae60d83
    SHA512 9a75624b0da46fed1b00e950a6501a4c21c5c74b7ecfbd8f58633805a26dfcaa8eed05f0795303bbe0c4fc55023b0f870bb5d429f161124bc66e3bddd57ca29b
    HEAD_REF master
    PATCHES
        "openssl_depend_libs.patch"
        "ignore_copying.patch"
        "install_dlls.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GETDNS_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" GETDNS_ENABLE_SHARED)

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
