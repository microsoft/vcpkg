vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ABRG-Models/morphologica
    REF "v${VERSION}"
    SHA512 8e113cc92fab08decbe2612055da1d9740fba305646c20bd60118dc1a0f0d5975db8d0e2d83004290bee1030c46d8095ffc092eae78c02cd834f0436fc65e2b3 
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
