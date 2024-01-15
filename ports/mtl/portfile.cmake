set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/Matrix-Template-Library-CPP
    REF 14079103842f542938f8988ed41189cf9e36c0ff
    SHA512 4d178071fff39b6d4d8d1169407a2fd5647088d28abf6727d2b6fd2b16f0f453bfce4c85b885abe70d293e4347b94cd654243ab20bb11824e59e67365305be90
    HEAD_REF vcpkg
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
