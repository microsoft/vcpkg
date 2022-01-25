vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/attica
    REF v5.89.0
    SHA512 46f4cb550a13032da2e48861916356f3dfa47de0e1c0672ffeea19bad813dfb5cdf1b45b1a25ff35adc07e622486b37d7a65ddf3d39c2b214114d916f09577bb
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Attica CONFIG_PATH lib/cmake/KF5Attica)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
