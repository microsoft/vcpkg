vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kpackage
    REF v5.87.0
    SHA512 254287e424045c357a3833c789e1640f1c2e44ed6884bd51f096d944f1945afac4cb921d2e85296741b119927a94b89cbc9a5e05f62be2831b9c04e7484fe62a
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Package CONFIG_PATH lib/cmake/KF5Package)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES kpackagetool5 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
