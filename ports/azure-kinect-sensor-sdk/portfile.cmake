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

vcpkg_download_distfile(DEPTHENGINE_ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Azure.Kinect.Sensor/${VERSION}"
    FILENAME "microsoft.azure.kinect.sensor.${VERSION}.nupkg.zip"
    SHA512 6e9e68f16bb00b3ddfdc963c6b62f9100d12b3407e0cd894052d5dc08ce2214e871f0c0977bff5b5e52af4ee325f775c818e2babacb6e8633b2887a9866c3ea3
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

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE "${DEPTHENGINE_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# Deploy depthengine blob
if (VCPKG_TARGET_IS_LINUX)
    file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
else()
    string(REPLACE "x64" "amd64" ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
    file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
      file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
