vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/glob
    REF "v${VERSION}"
    SHA512 2213c416d40dcd3a9e03c64a8d24d24d3d3c78847481efe4f10b26cd63b983a03e5ec5ea77dc0a0461a832793927e0bf237b7a47088fe99dafbb83aa482d2fe8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
