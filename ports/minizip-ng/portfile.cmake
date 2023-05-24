if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/minizip-ng
    REF 241428886216f0f0efd6926efcaaaa13794e51bd #v3.0.7
    SHA512 779a53fafe63b64f5f703448262871c323f5753cbb58001dd0d0ef10de8d3bd7bb6055db4e763e664ccb5b781ce8dd06bf7c3e6b38eca019de835322a833fa06
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
