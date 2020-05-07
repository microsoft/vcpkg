set(VERSION 1.4.0-alpha.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Azure-Kinect-Sensor-SDK
    REF v${VERSION}
    SHA512 bf09ff92dc1b8621a941d838aef9c804bb5635f7984b7f86f01a38441d44935db764b69483d598e1f2c0aafb5c7ec196ef9c722967d92e6d075cb67ce781fea9
    HEAD_REF master
    PATCHES
        fix-builds.patch
        disable-c4275.patch
        fix-dependency-imgui.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    docs K4A_BUILD_DOCS
    tool BUILD_TOOLS
)

# .rc file needs windows.h, so do not use PREFER_NINJA here
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
    -DK4A_SOURCE_LINK=OFF
    -DK4A_MTE_VERSION=ON
    -DBUILD_EXAMPLES=OFF
    -DWITH_TEST=OFF
    -DIMGUI_EXTERNAL_PATH=${CURRENT_INSTALLED_DIR}/include/bindings
)

vcpkg_install_cmake()

# Avoid deleting debug/lib/cmake when fixing the first cmake
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/k4a TARGET_PATH share/k4a)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/k4arecord TARGET_PATH share/k4arecord)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if ("tool" IN_LIST FEATURES)
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        file(GLOB AZURE_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        file(COPY ${AZURE_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE ${AZURE_TOOLS})
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(GLOB AZURE_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        file(REMOVE ${AZURE_TOOLS})
    endif()
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Install Depth Engine
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Azure.Kinect.Sensor/${VERSION}"
    FILENAME "azure-kinect-sensor-sdk.zip"
    SHA512 6c15975e7c834672de723b0c474fa4cd58f41c5bee6511dcbdbc22f1a58daa906c4f01a7e941af0e7d09f763ff886015c1f6b1e29b6bdfb333f10857edfec2ca
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

set(ARCHITECTURE "")
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    set(ARCHITECTURE "x86")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(ARCHITECTURE "amd64")
else ()
    message(FATAL_ERROR "this architecture is not supported.")
endif ()

file(COPY ${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/bin/k4a)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/k4a)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)