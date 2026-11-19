vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/rhasheq
    REF "${VERSION}"
    SHA512 a4fe4fe1abb4e39f4fce8e34e6146d007e82d8e1d6400cbbd1fb3e68fdb424e2b3bbc68f7cf6882775065e4318a92b85fac6c2244f2ffe435da69630e91e19eb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DRHASHEQ_BUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
