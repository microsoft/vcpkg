vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 63b229c756202525d1c90d21706fdfb744096220
    SHA512 610b40b6a967fcce9494478d4518e2529be328ce2aaccbedab8d2264d19d2791e427f51b48886fceacafecf74f24a3d25a9dd54697d375bdc8414521cce579a5
    HEAD_REF master
    PATCHES
)

# Because status-code's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -Dstatus-code_IS_DEPENDENCY=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Boost
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/status-code)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
