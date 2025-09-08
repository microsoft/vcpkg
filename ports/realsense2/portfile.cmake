vcpkg_download_distfile(lz4_patch
    URLS https://github.com/IntelRealSense/librealsense/commit/20748445a8e24bee148d8b6f67f3a6c3f259cced.diff?full_index=1
    SHA512 90d754e7da6931b607429035c2fa14aa1137e28fa88d04f5e90220f57fc808fd256b516840922d0938d6b0f3f30b937ddc3568865c9a21fa1a2d8a51788e6f9a
    FILENAME IntelRealSense-librealsense-lz4.diff
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF "v${VERSION}"
    SHA512 5b5998560ab6a7d81a23b1d84194f4cf3e123af1d46711127d838dc37c3eb1414f232bf0e1a444c68212fabcd79c3e4e1c47ff87b878266558e0027bd522447f
    HEAD_REF master
    PATCHES
        add-include-chrono.patch # https://github.com/IntelRealSense/librealsense/pull/13537
        android-config.diff
        build.diff
        "${lz4_patch}"
        devendor-lz4.diff # https://github.com/IntelRealSense/librealsense/pull/13803#issuecomment-3072432118
        devendor-nlohmann-json.diff
        devendor-stb.diff
        fix_openni2.patch
        libusb.diff
        using-firmware.diff
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

file(READ "${SOURCE_PATH}/common/fw/firmware-version.h" firmware_version_h)
string(REGEX MATCH "D4XX_RECOMMENDED_FIRMWARE_VERSION \"([0-9]+.[0-9]+.[0-9]+.[0-9]+)\"" unused "${firmware_version_h}")
set(firmware_filename "D4XX_FW_Image-${CMAKE_MATCH_1}.bin")
vcpkg_download_distfile(firmware_distfile
    URLS "https://librealsense.intel.com/Releases/RS4xx/FW/${firmware_filename}"
    SHA512 c465cedba2a8df713fb7900bb60a448b15e53ac013175cf7c152909bc9f2324cf46efd1323954633d7c011e33a27f9426eb1347ad48d92839a68c7e4fa680f94
    FILENAME "IntelRealSense-${firmware_filename}"
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
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DENABLE_CCACHE=OFF
        -DENFORCE_METADATA=ON
        "-DFIRMWARE_DISTFILE=${firmware_distfile}"
        "-DOPENNI2_DIR=${CURRENT_INSTALLED_DIR}/include/openni2"
        -DUSE_EXTERNAL_LZ4=ON
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
