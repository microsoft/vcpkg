vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfigwidgets
    REF v5.84.0
    SHA512 89f2b0d4494cca9a95550ef08ec62fa5fc4dddfacf6b15a0679513cd1d0210411a8d9333598be5cee76fe6ff0dcd4cc45b7b36ca6cb950e04c08ba3757248117
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designerplugin BUILD_DESIGNERPLUGIN
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5ConfigWidgets CONFIG_PATH lib/cmake/KF5ConfigWidgets)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)