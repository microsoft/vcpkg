vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Azure-Kinect-Sensor-SDK
    REF "v${VERSION}"
    SHA512 34db933c56fc4c5f38db54a10e0e9cfcfce536d21d1a1c963f33c038d83eb5e90fc28d6360b3c737b54118878e062860c43c2e051f8030b205f640ad1f2d3a94
    HEAD_REF master
    PATCHES
        fix-builds.patch
        fix-linux.patch
        fix-calibration-c.patch
        fix-build-imgui.patch
        fix-header.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool    BUILD_TOOLS
)

# .rc file needs windows.h, so do not use PREFER_NINJA here
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0072=NEW
        -DBUILD_EXAMPLES=OFF
        -DK4A_SOURCE_LINK=OFF
        -DK4A_MTE_VERSION=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/k4a" PACKAGE_NAME "k4a" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/k4arecord" PACKAGE_NAME "k4arecord")

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES k4arecorder k4aviewer AzureKinectFirmwareTool AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
