vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF v5.88.0
    SHA512 233ea884aafc70a186698fece376727cac5ae79daa6396752a375c8b66c6bbf9ea952ee14cd48b54fcf58af2f931d9c96a83f3d01c8e2c29ab618ee961285762
    HEAD_REF master
    PATCHES
        use_cmake_to_find_zstd.patch # https://invent.kde.org/frameworks/karchive/-/merge_requests/24
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "lzma"  CMAKE_DISABLE_FIND_PACKAGE_LibLZMA
        "zstd"  CMAKE_DISABLE_FIND_PACKAGE_ZSTD
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
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

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")


