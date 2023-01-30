vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF v5.98.0
    SHA512 3477280f319cb37e18c59d874f5bcf4db5c76e3572af6e2c91bad1135f16a2eb1c9fcc0ec9895790031e6d459b94eeb14be10ea7aab0660d037241bdf6662358
    HEAD_REF master
    PATCHES
        control-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "bzip2" VCPKG_USE_BZIP2
        "lzma"  VCPKG_USE_LIBLZMA
        "zstd"  VCPKG_USE_ZSTD
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Archive CONFIG_PATH lib/cmake/KF5Archive)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

