if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/minizip-ng
    REF 3.0.5
    SHA512 da0c230951caafd986331300b840d09a4c27a677183174f8b1782c2515209b51cf00133dd5fc5f9fc88a349134db7f93d3daa7c05b7d0270be99b9cf85a6c133
    HEAD_REF master
    PATCHES 
        Modify-header-file-path.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pkcrypt MZ_PKCRYPT
        signing MZ_SIGNING
        wzaes MZ_WZAES
        openssl MZ_OPENSSL
        bzip2 MZ_BZIP2
        lzma MZ_LZMA
        zlib MZ_ZLIB
        zstd MZ_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DMZ_FETCH_LIBS=OFF
        -DMZ_PROJECT_SUFFIX:STRING=-ng
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
