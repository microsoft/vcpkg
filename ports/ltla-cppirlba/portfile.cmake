vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppIrlba
    REF "v${VERSION}"
    SHA512 7ddeccfe0a0810e32fb4385cf5a6545831764acb0ea2c96373228beceee897b20251391421b85b08e51baf8d5dca7c4b88347145a784ec6d7c3e11ff05a1c5ad
    HEAD_REF master
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
