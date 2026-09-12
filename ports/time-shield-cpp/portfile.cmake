vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LimiNode/time-shield-cpp
    REF "v${VERSION}"
    SHA512 797db81c078e83313787cbc272756bf662fd42de9961dfb7427c39ee443c03c02f8c59cdfda53a08bd4378011488a9caae13632718f6f8f34d395eaf7543c75c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTIME_SHIELD_CPP_BUILD_EXAMPLES=OFF
        -DTIME_SHIELD_CPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME TimeShield
    CONFIG_PATH lib/cmake/TimeShield
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
