set(GETDNS_VERSION 1.7.0)
set(GETDNS_HASH d09b8bdd0b4a3df2d25b9689166226da83a5a7eb2c7436487dc637539ac6077624a4d66cf684c4e6c4911561872c6bd191af3afd90d275b1662e4c6c47773ef6)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GETDNS_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" GETDNS_ENABLE_SHARED)

vcpkg_download_distfile(ARCHIVE
    URLS "https://getdnsapi.net/dist/getdns-${GETDNS_VERSION}.tar.gz"
    FILENAME "getdns-${GETDNS_VERSION}.tar.gz"
    SHA512 ${GETDNS_HASH}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES disable-install-COPYING-in-config-step.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libevent BUILD_LIBEVENT2
        libuv BUILD_LIBUV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_GETDNS_QUERY=OFF
        -DBUILD_GETDNS_SERVER_MON=OFF
        -DENABLE_STATIC=${GETDNS_ENABLE_STATIC}
        -DENABLE_SHARED=${GETDNS_ENABLE_SHARED}
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DENABLE_STUB_ONLY=ON #if setting ON, it will require libunbound to build on Unix platform.
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()