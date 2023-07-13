vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/asl
    REF 934d34719c8a620fcf16ae5a3c00c326eb22e748
    SHA512 b6fcb3dcb53a53d975666db1643d7ea518246e8fb6745621ce4b63de4393f7767844e9241baa6fdf1a45c241a9aa0866844c47deec0020313278128cccff6869
    HEAD_REF master
    PATCHES
        workaround-msvc-optimizer-ice.patch
        fix-crt-linkage.patch # CRT linkage uses C/CXX FLAGS in vcpkg
        install-extra-headers.patch
        install-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_MCMODELLARGE=OFF
        -DBUILD_DYNRT_LIBS=OFF # CRT linkage uses C/CXX FLAGS in vcpkg
        -DBUILD_MT_LIBS=OFF # CRT linkage uses C/CXX FLAGS in vcpkg
        -DBUILD_CPP=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-asl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# from ampl-mp license
file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
