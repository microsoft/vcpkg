vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF "${VERSION}"
    SHA512 c7d2a39c70985906f8dd8157e3aee78b4fe49676b3837749f87526dbde8905d4e93945b90ba427c563884a8a9210434a972e0126f9a13348dce91947565e03d0
    HEAD_REF release
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME lyra
    CONFIG_PATH share/lyra/cmake
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
