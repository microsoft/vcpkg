vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realsenseai/librealsense
    REF "v${VERSION}"
    SHA512 adedd675861e542c4701ab12af8000ab7cd2b675a88d59c3463292a94ed840c8e8dead200b24de3e1926634a2b2736e0f5b304c2639d769762fe74bfc38b4c40
    HEAD_REF master
    PATCHES
        android-config.diff
        devendor-lz4.diff
        devendor-stb.diff
        fix_openni2.patch
        libusb.diff
        disable-network-check.diff
        disable-udev.diff
        # This pkg-config fix targets vcpkg's external dependencies and disabled DDS/rosbag2.
        # Upstreaming requires handling bundled dependencies and enabled DDS/rosbag2,
        # preserving CMake 3.10 compatibility, and supporting multi-config generators.
        fix-pkgconfig.diff
)
file(GLOB extern "${SOURCE_PATH}/CMake/extern_*.cmake")
file(REMOVE_RECURSE
    ${extern}
    "${SOURCE_PATH}/third-party/easyloggingpp"
    "${SOURCE_PATH}/third-party/realsense-file/lz4"
    "${SOURCE_PATH}/third-party/stb_easy_font.h"
    "${SOURCE_PATH}/third-party/stb_image.h"
    "${SOURCE_PATH}/third-party/stb_image_write.h"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openni2         BUILD_OPENNI2_BINDINGS
        rs-usb-backend  FORCE_RSUSB_BACKEND
        tools           BUILD_TOOLS
)

if("rs-usb-backend" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND FEATURE_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_EASYLOGGINGPP=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        -DBUILD_RS2_ALL=NO
        -DBUILD_ROSBAG2=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DCHECK_FOR_UPDATES=OFF
        -DENABLE_AI_ASSISTANT=OFF
        -DENABLE_CCACHE=OFF
        -DENABLE_STATS=OFF
        -DENFORCE_METADATA=ON
        "-DOPENNI2_DIR=${CURRENT_INSTALLED_DIR}/include/openni2"
        -DUSE_EXTERNAL_LZ4=ON
        -DUSE_EXTERNAL_NLOHMANN_JSON=ON
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        OPENNI2_DIR
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/realsense2)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(BUILD_TOOLS)
    set(TOOL_NAMES rs-convert rs-embed rs-enumerate-devices rs-fw-logger rs-fw-update rs-record rs-terminal)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(BUILD_OPENNI2_BINDINGS)
    file(GLOB RS2DRIVER "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_out/rs2driver*")
    if(RS2DRIVER)
        file(COPY ${RS2DRIVER} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/openni2/OpenNI2/Drivers")
    endif()
endif()

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
set(copyright_files
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/third-party/rapidxml/LICENSE"
    "${SOURCE_PATH}/third-party/rapidxml/rapidxml_utils.hpp"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/cpp_common/include/ros/header.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/cpp_common/include/ros/datatypes.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/cpp_common/include/ros/cpp_common_decl.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/cpp_common/include/ros/macros.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/msgs/sensor_msgs/point_field_conversion.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/roslz4/include/roslz4/lz4s.h"
    "${SOURCE_PATH}/third-party/realsense-file/rosbag/roslz4/src/xxhash.h"
)
if(VCPKG_TARGET_IS_OSX)
    # Upstream's aggregate notice contains the BSD license selected for HIDAPI.
    list(APPEND copyright_files
        "${SOURCE_PATH}/NOTICE.md"
    )
endif()
if(BUILD_TOOLS)
    list(APPEND copyright_files
        "${SOURCE_PATH}/third-party/tclap/COPYING"
        "${SOURCE_PATH}/third-party/tclap/include/tclap/MultiSwitchArg.h"
        "${SOURCE_PATH}/third-party/tclap/include/tclap/ArgTraits.h"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})
