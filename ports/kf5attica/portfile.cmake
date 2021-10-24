vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/attica
    REF v5.87.0
    SHA512 8d6635e9670713c2ef3101d3c0dbeaab7c34d046010cfef898783eac68980c9bf07d5d09cf00fe3e8862e1e4f5f34b48fd10dfdb69b3744dc5cf13b034522b10
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Attica)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

