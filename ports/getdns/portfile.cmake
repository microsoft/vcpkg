string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GETDNS_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" GETDNS_ENABLE_SHARED)

vcpkg_download_distfile(ARCHIVE
    URLS "https://getdnsapi.net/dist/getdns-${VERSION}.tar.gz"
    FILENAME "getdns-${VERSION}.tar.gz"
    SHA512 d5725a24378b6fe0018daefdaba5565d2d4d51109ef66609fc34270a0a69accb95f5f895d0cdfc5caca51d2ec586db126f367439f05aed12507395af26739e2f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES 
        disable-docs.patch
        fix-include.patch
	fix-libuv-deps.patch
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

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
