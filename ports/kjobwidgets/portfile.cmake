vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kjobwidgets
    REF "v${VERSION}"
    SHA512 5f39574dc8589a5ef87fce979da2c9cbde1c275c6bbba0c094983f4bce6ade574f498612da534216b1f34ccfe18596d75857cafb36f049bdb77c5bacf6d807b0
    HEAD_REF master
    PATCHES
        001_fix_static_dependencies.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=ON -DWITH_X11=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=OFF -DWITH_X11=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DBUILD_PYTHON_BINDINGS=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        WITH_X11
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6jobwidgets CONFIG_PATH lib/cmake/KF6JobWidgets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
