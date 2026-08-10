vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF "v${VERSION}"
    SHA512 689dad3413937433181632ea3cc3fb5d360b99dbc29ed93c76be59a403ac6b4ce51df7a33d85f9a9c9c87939e94f419d4f7c45942cc608c21e78448945e9464c
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
