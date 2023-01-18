# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO casbin/casbin-cpp
    REF "v${VERSION}"
    SHA512 312090ee3c41a138aeefe06544a24d72c6192b1dbb223d83821b790d02c44db23e6f6bc81e693abb0a928820da5feb83bac9c4b6337c15b6bc35325c488d335a
    HEAD_REF master
    PATCHES
        json.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCASBIN_BUILD_TEST=OFF
        -DCASBIN_BUILD_BENCHMARK=OFF
        -DCASBIN_BUILD_PYTHON_BINDINGS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
