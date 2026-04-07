vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ki18n
    REF "v${VERSION}"
    SHA512 85ad784de2588777920994f88ddcccfad2549c96ed054d5012df887ace9b89696e0e9d22e623b4a936ceaed3de06d3a8d2bb1feeaa47628587bd1c0cb6c089af
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml BUILD_WITH_QML
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DPython3_EXECUTABLE=${PYTHON3}
        -DFALLBACK_KI18N_PYTHON_EXECUTABLE=${PYTHON3}
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF6I18n)
vcpkg_copy_pdbs()

# KF6I18nMacros.cmake embeds the Python executable path used at build time as a
# fallback. This is an absolute path but is ultimately relocatable, so skip the check.
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
