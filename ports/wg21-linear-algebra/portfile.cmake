vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BobSteagall/wg21
    REF v0.7.2
    SHA512 c249344d035d09760a9e5ea059ed6db5a1cb42b918735672bd7aa6dbda08f947855582f76ad61d33f59a847d8befe5caed57d25da2bcfc9fa8e6cef50a4c24e2
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS -DLA_INSTALL=1 -DLA_BUILD_PACKAGE=0 -DLA_ENABLE_TESTS=0
)

vcpkg_install_cmake()

vcpkg_cmake_config_fixup(PACKAGE_NAME wg21_linear_algebra
                         CONFIG_PATH lib/cmake/wg21_linear_algebra)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib")
