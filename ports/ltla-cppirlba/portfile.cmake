vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppIrlba
    REF "v${VERSION}"
    SHA512 50233166652ca773b3c8fd46ecadb51aaef749540390b56d0f24717859328a1d565b1133d08e23d3db70d052ec581120786d5eeec8d0678aee874b2aaf7b509f
    HEAD_REF master
    PATCHES
        0001-fix-eigen3.patch
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIRLBA_FETCH_EXTERN=OFF
        -DIRLBA_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_irlba
    CONFIG_PATH lib/cmake/ltla_irlba
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
