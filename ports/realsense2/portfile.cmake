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
        android-config.diff
        build.diff
        fix_openni2.patch
        fix-nlohmann_json.patch
        add-include-chrono.patch #https://github.com/IntelRealSense/librealsense/pull/13537
        "${lz4_patch}"
        lz4-embed.diff # https://github.com/IntelRealSense/librealsense/pull/13803#issuecomment-3072432118
)
file(REMOVE_RECURSE
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_EASYLOGGINGPP=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DENABLE_CCACHE=OFF
        -DENFORCE_METADATA=ON
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
