vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/Matrix-Template-Library-CPP
    REF 733c95a93155468994b3bcacab1b8953478eb210
    SHA512 f654b12e19c0981fe1c15d44ffa068019ec5323b78409a46eab17af09b49ea511903b49fd004ceccf3f0ca016604484943f3ade9ca411b821351364ad227f57f
    HEAD_REF vcpkg
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMTL_CMAKE_DIR=share/mtl
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "mtl" CONFIG_PATH "lib/cmake/mtl")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


