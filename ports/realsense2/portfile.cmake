vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF "v${VERSION}"
    SHA512 e38350be3eba6fec97096abfff652a36d0e37ba95baf1b40841cc180e2d650c9abfa53d99e1c0a7767fa0c91ac4d9780702b51078f9c1564848121c1048749f4
    HEAD_REF master
    PATCHES
        android-config.diff
        build.diff
        devendor-lz4.diff # https://github.com/IntelRealSense/librealsense/pull/13803#issuecomment-3072432118
        devendor-nlohmann-json.diff
        devendor-stb.diff
        fix_openni2.patch
        libusb.diff
        using-firmware.diff
        add-stdexcept.diff # https://github.com/IntelRealSense/librealsense/pull/14299
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
    SHA512 1098738b754d14bcf529541986e0c39c9efd481cae3954f5f01233b12859e289bfa62b97c06ce644b7ce704ed8cab066f1bd91cbe2287cc6cc20a671213cdcff
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
