vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/flagpp
    REF "v${VERSION}"
    SHA512 82e07880105495213f8a78dba42bf3fb36d862e891280cca1ea02b694d6cc33f72903817e74e48d701ffa901ab0f9604f3204631256974afd7a755153a106e29
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
