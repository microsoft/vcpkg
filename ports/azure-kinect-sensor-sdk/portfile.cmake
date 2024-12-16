set(VERSION 1.4.1)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Azure-Kinect-Sensor-SDK
    REF "v${VERSION}"
    SHA512 ef94c072caae43b0a105b192013e09082d267d4064e6676fac981b52e7576a663f59fcb53f0afe66b425ef2cea0cb3aa224ff7be6485c0b5543ff9cdabd82d4d
    HEAD_REF master
    PATCHES
        fix-builds.patch
        fix-dependency-imgui.patch
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
        docs K4A_BUILD_DOCS
        tool BUILD_TOOLS
)

# .rc file needs windows.h, so do not use PREFER_NINJA here
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
    "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    ${FEATURE_OPTIONS}
    -DK4A_SOURCE_LINK=OFF
    -DK4A_MTE_VERSION=ON
    -DBUILD_EXAMPLES=OFF
    -DWITH_TEST=OFF
    -DIMGUI_EXTERNAL_PATH="${CURRENT_INSTALLED_DIR}/include/bindings"
)

vcpkg_cmake_install()

# Avoid deleting debug/lib/cmake when fixing the first cmake
if(NOT VCPKG_BUILD_TYPE)
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/share")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/share")

vcpkg_cmake_config_fixup(PACKAGE_NAME k4a CONFIG_PATH share/k4a)
vcpkg_cmake_config_fixup(PACKAGE_NAME k4arecord CONFIG_PATH share/k4arecord)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES k4arecorder k4aviewer AzureKinectFirmwareTool AUTO_CLEAN)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Install Depth Engine
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Azure.Kinect.Sensor/${VERSION}"
    FILENAME "azure-kinect-sensor-sdk_17630a00.zip"
    SHA512 17630a00f4e9ff3ef68945b62021f6d0390030b43c120c207afe934075a7a87c5848be1f46f4c35c7ecd5698012452ffcbb67f739e9048857410ec7077e5e8c6 
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(ARCHITECTURE "x86")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(ARCHITECTURE "amd64")
else ()
    message(FATAL_ERROR "this architecture is not supported.")
endif ()

if (VCPKG_TARGET_IS_LINUX)
    file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
else()
    file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/azure-kinect-sensor-sdk")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/azure-kinect-sensor-sdk")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/azure-kinect-sensor-sdk")
      file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/azure-kinect-sensor-sdk")
    endif()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
