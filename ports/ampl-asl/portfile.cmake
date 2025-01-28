vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/asl
    REF 2f5d9de248c53a3063bba23af2013cd3db768bf8
    SHA512 a551420f60b2419285195063fc42b208e59f076d1d00e4b90847c15613997ba35d319d57275687df37e74a7486420fec2cde7da71a6126802ed19a12dcb8ffdc
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
