
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/forge
    REF v1.0.8
    SHA512 08e5eb89d80f7fa3310f0eb37481492b5c1dfff00b33c308169862d8b25cf93ad1d9c0db78667c0207a7f6f8ca4046c196bd3a987af839ea1864b49c738ee8e3
    HEAD_REF master
    PATCHES cmake_config.patch
)
file(REMOVE "${SOURCE_PATH}/CMakeModules/FindOpenGL.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFG_BUILD_DOCS=OFF
        -DFG_BUILD_EXAMPLES=OFF
        -DFG_INSTALL_BIN_DIR=bin
        -DFG_INSTALL_CMAKE_DIR=share/forge
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/bin/* ${CURRENT_PACKAGES_DIR}/debug/bin/*)
list(FILTER DLLS EXCLUDE REGEX "forge\\.dll\$")
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/forge/examples
    ${CURRENT_PACKAGES_DIR}/forge/examples
    ${DLLS}
)

file(INSTALL "${SOURCE_PATH}/.github/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
