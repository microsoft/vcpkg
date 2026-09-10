vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ki18n
    REF "v${VERSION}"
    SHA512 79e58072cd8893a50af351feb7c7f9f5c1c21064c87358b5794b9913c310438f1338728b4ae75dc4969e576fe1cf56b02e07dfe570fef7ee54d5f4f28ade2387
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml       BUILD_WITH_QML
        isocodes  CMAKE_DISABLE_FIND_PACKAGE_IsoCodes
    INVERTED_FEATURES
        isocodes  CMAKE_REQUIRE_FIND_PACKAGE_IsoCodes
)

vcpkg_find_acquire_program(PYTHON3)
if(CMAKE_REQUIRE_FIND_PACKAGE_IsoCodes)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DPython3_EXECUTABLE=${PYTHON3}
        -DFALLBACK_KI18N_PYTHON_EXECUTABLE=${PYTHON3}
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qmls
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6i18n
    CONFIG_PATH lib/cmake/KF6I18n
)
vcpkg_copy_pdbs()

# KF6I18nMacros.cmake embeds the Python executable path used at build time as a
# fallback. This is an absolute path but is ultimately relocatable, so skip the check.
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
