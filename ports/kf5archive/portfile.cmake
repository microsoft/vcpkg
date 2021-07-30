vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF v5.84.0
    SHA512 82926f62424446df0f4fc300f57ae9bd5baf8e13da2ce4135ac56c0c52a0307bffb06f84ac7e8e658e96ace2ae3d530f27e232061284ac87271404f218e9fdd4
    HEAD_REF master
    PATCHES
        9ab5f2bf.patch # https://invent.kde.org/frameworks/karchive/-/commit/9ab5f2bfbe59038b0d0b6ca7f1b22d1c9229c67e
        5a79756f.patch # https://invent.kde.org/frameworks/karchive/-/commit/5a79756f381e1a1843cb2171bdc151dad53fb7db
        23.patch # https://invent.kde.org/frameworks/karchive/-/merge_requests/23
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    INVERTED_FEATURES
        "lzma"  CMAKE_DISABLE_FIND_PACKAGE_LibLZMA
        "zstd"  CMAKE_DISABLE_FIND_PACKAGE_PkgConfig
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Archive)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
