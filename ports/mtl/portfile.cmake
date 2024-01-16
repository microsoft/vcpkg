set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/Matrix-Template-Library-CPP
    REF a4dd0f6583ca41ba203930edfecfad00cb94c82e
    SHA512 f43780eb4c02de3661fd26f079f0fe300e5321fbd81f689592ce943089f6ef3ef28f1bfe606e576969cbde221d543e2b7307f95434c2a38da94359127b9cdd03
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "mtl" CONFIG_PATH "lib/cmake/mtl")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


