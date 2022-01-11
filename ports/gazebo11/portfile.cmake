vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/gazebo
    REF 8cddf1da9e9e6b380bc43bc1ed8b7879d2007ce6
    SHA512 c3bb063eda1660d4c55f1c6fce1877b0e7562a5f77035934542cb20f24e538726208776c06a7bc1fdefda3b7d4a9be3a64b725d416092a7527b84c2de18f4ed9
    HEAD_REF gazebo11
    PATCHES
        0001-Fix-deps.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openal    HAVE_OPENAL
        ffmpeg    FFMPEG_FEATURE
        gts       GTS_FEATURE
    INVERTED_FEATURES
        simbody   CMAKE_DISABLE_FIND_PACKAGE_Simbody
        dart      CMAKE_DISABLE_FIND_PACKAGE_DART
        bullet    CMAKE_DISABLE_FIND_PACKAGE_BULLET
        libusb    NO_LIBUSB_FEATURE
        gdal      NO_GDAL_FEATURE
        graphviz  NO_GRAPHVIZ_FEATURE
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/debug/bin")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/bin")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_EXTERNAL_TINY_PROCESS_LIBRARY=ON
        -DPKG_CONFIG_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/pkgconf/pkgconf.exe
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/gazebo")

vcpkg_copy_tools(
    TOOL_NAMES gazebo gz gzclient gzserver
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gazebo11" RENAME copyright)
