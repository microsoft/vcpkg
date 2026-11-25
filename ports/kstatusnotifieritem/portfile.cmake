vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kstatusnotifieritem
    REF "v${VERSION}"
    SHA512 f8f66b08941224a2fa7de47ed1d3906e5244951f303dccb437fa76c8f40ade71c4db8203ef64b210446f220588dc4ca04859e0f0b7e064b326ce3db152733e86
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_BSD)
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=ON -DWITHOUT_X11=OFF -DCMAKE_REQUIRE_FIND_PACKAGE_X11=ON)
else()
    list(APPEND FEATURE_OPTIONS -DUSE_DBUS=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6statusnotifieritem CONFIG_PATH lib/cmake/KF6StatusNotifierItem)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
# ecm_create_qm_loader() compiles ECM's BSD-3-Clause ECMQmLoader.cpp.in into the library
list(APPEND LICENSE_FILES "${CMAKE_CURRENT_LIST_DIR}/ECMQmLoader-copyright.txt")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
