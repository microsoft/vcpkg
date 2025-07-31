vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/ereignis
    REF "v${VERSION}"
    SHA512 73b9fbf01caee6f0cc49de771ee5fc5e1da208acd2d3d40647c3e9c19df121b05c3403393539fa4bb510cb8e58769fe9afa5b036ce04c564266fc49b8ddea8e5
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
