vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realsenseai/librealsense
    REF "v${VERSION}"
    SHA512 2c627d62c21ab4e5c81bd3a1c44c60a3f5e2233c99cc1461a63609ef92f7ada128737cabe8a56bb6f3c761a569747820e4b05e7b8f0f4ec75e3b617154a971fa
    HEAD_REF master
    PATCHES
        android-config.diff
        devendor-lz4.diff
        devendor-stb.diff
        fix_openni2.patch
        libusb.diff
        disable-network-check.diff
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
        -DENABLE_CCACHE=OFF
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
