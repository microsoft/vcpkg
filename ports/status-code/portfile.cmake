vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 6bd2d565fd4377e16614c6c5beb495c33bfa835b
    SHA512 48f566f18643f6014e2fa542884fe077820c751cd0c03c9003e125ee547fa8e78963301e61b6ebdb834a12e7cec7fa3551268ef5ae9a434328321d6825aa72e3
    HEAD_REF master
    PATCHES
        add-missing-include.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Boost
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/status-code)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
