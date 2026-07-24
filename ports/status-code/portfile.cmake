vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 937b0fc71c85dcae77059f4a3bec6424fdf1b5f9
    SHA512 f0d71b0a6982261fcb41f75cdb49c035fac00a5cd9e61b706c606dc255775c48af2ba15772c19330cf5497e787af6c455b097233554f3f2d2ffd72a9fb79a08c
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
