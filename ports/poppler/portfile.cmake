vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freedesktop/poppler
    REF poppler-20.12.1
    SHA512 f692682689c0b0fcc3953a1cc157b6e1d2ce3ccab185189d6dc0807f1dd3ea2d1a9773d0b805079a30b3c8a3b0cf3ee83239ed48d7b08dc7762eba29c2033674
    HEAD_REF master
    PATCHES
        0001-remove-CMAKE_CXX_STANDARD.patch
        0002-remove-test-subdirectory.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    zlib ENABLE_ZLIB
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_GTK_TESTS=OFF
        -DBUILD_QT5_TESTS=OFF
        -DBUILD_QT6_TESTS=OFF
        -DBUILD_CPP_TESTS=OFF
        -DENABLE_UTILS=OFF
        -DENABLE_GLIB=OFF
        -DENABLE_GLOBJECT_INTROSPECTION=OFF
        -DENABLE_QT5=OFF
        -DENABLE_QT6=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)