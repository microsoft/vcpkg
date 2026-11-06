vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/asl
    REF "v${VERSION}"
    SHA512 cd4092f6ff4852ecefbbc803bf0c23cc86529fddd8159084c7a45ebf3a542c24f497d8c0457e7fac8aa21b192b0ab3eca1ab9517e68832e028e052ed25a9ed22
    HEAD_REF master
    PATCHES
        workaround-msvc-optimizer-ice.patch
        0006-disable-generate-arith-h.diff
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

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
