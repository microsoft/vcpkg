set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO romanpauk/dingo
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 d40def7e3f28675dd399703f0f5890822503e5b8dcfcd96628010dc9854b61dbac9e3cb863740a40744abca0eae3ad69c21b3c17202c5d68cc17a22faab9830c
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDINGO_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

