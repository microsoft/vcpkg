vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/sonnet
    REF v5.98.0
    SHA512 7bd4dc164e049e9b5be2f29a81444f4545bb0c70db8ede0cc4303292d983e21c6701ac9ab02f4b4b3b2793ec7e6a078601e8c7cf083b1a799d10dc9f1d5a57c0
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "hunspell"    CMAKE_REQUIRE_FIND_PACKAGE_HUNSPELL
  INVERTED_FEATURES
    "hunspell"    CMAKE_DISABLE_FIND_PACKAGE_HUNSPELL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qml
        -DCMAKE_DISABLE_FIND_PACKAGE_VOIKKO=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ASPELL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_HSPELL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Sonnet CONFIG_PATH lib/cmake/KF5Sonnet)

vcpkg_copy_tools(
    TOOL_NAMES gentrigrams parsetrigrams
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/gentrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/parsetrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX}")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

