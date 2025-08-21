vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 525e324b1b85fbd1bf74046d760068b7e27b8cda
    SHA512 c70a33558e7399aff5d069ddd032ed5896ab2f0075bc864f12f335c1e7023be95503f5ee9dec481fd30b2fbb72611847e50653113a77aa4032121f87f6eb8377
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
