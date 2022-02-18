vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shibatch/sleef
    REF 3.5.1
    SHA512 e8e4e5028db52998c6b82bd462622c08d670e4e85273327f1c3bdbd900827dd7793b217c2876ca1229b6f672493bb96f40140e14366390cccea0e6780689e128
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_LIBM=ON
        -DBUILD_DFT=ON
        -DBUILD_QUAD=ON
        -DBUILD_GNUABILIBS=${VCPKG_TARGET_IS_LINUX}
        -DBUILD_TESTS=OFF
        -DBUILD_INLINE_HEADERS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
