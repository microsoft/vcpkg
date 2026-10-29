vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF "v${VERSION}"
    SHA512 8bddcfa87a9a1b69c1dace226b59b1deec1fbcb5ee0aba31539cb8db52ae411588fda681429fd10485b9ab108f370920da650d65c5e0b513a21c651599e988f9
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6dbusaddons
    CONFIG_PATH lib/cmake/KF6DBusAddons
)
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin")
    else()
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin/kquitapp6${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/bin/kquitapp6${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
