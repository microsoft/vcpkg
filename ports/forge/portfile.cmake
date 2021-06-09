if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "This port currently only supports x64 architecture")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/forge
    REF v1.0.7
    SHA512 d341d5c6bdccf7d2f085162d1d8209b0b28d73b8a9f3173546b26f06bf8e422b3fdf1cfbaa7d122ea75cee5cf5f6bb6dbd2bffc10d8e0c336b5b8695c39f7b54
    HEAD_REF master
    PATCHES cmake_config.patch
)
file(REMOVE ${SOURCE_PATH}/CMakeModules/FindOpenGL.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFG_BUILD_DOCS=OFF
        -DFG_BUILD_EXAMPLES=OFF
        -DFG_INSTALL_BIN_DIR=bin
        -DFG_INSTALL_CMAKE_DIR=share/Forge
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/Forge TARGET_PATH share/Forge)

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/bin/* ${CURRENT_PACKAGES_DIR}/debug/bin/*)
list(FILTER DLLS EXCLUDE REGEX "forge\\.dll\$")
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/examples
    ${CURRENT_PACKAGES_DIR}/examples
    ${DLLS}
)

file(INSTALL ${SOURCE_PATH}/.github/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
