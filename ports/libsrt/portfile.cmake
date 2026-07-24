vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Haivision/srt
    REF "v${VERSION}"
    SHA512 afb35de76be5c1b8558b3956586b8b7b044aa7709d7ce1b99b6b55e54f72c604eea50ae44962985c68ef681a69accb0a2a7f6a8678b8165e2aeee93632a0ff2f
    HEAD_REF master
    PATCHES
        fix-static.patch
        pkgconfig.diff
        fix-tool.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool    ENABLE_APPS
        bonding ENABLE_BONDING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DENABLE_CXX11=ON
        -DENABLE_STATIC=${KEYSTONE_BUILD_STATIC}
        -DENABLE_SHARED=${KEYSTONE_BUILD_SHARED}
        -DENABLE_UNITTESTS=OFF
        -DUSE_OPENSSL_PC=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(ENABLE_APPS)
    if(NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_copy_tools(TOOL_NAMES srt-tunnel AUTO_CLEAN)
    endif()
    vcpkg_copy_tools(TOOL_NAMES srt-file-transmit srt-live-transmit AUTO_CLEAN)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/srt-ffplay" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/srt-ffplay")
endif()
if(KEYSTONE_BUILD_STATIC OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/srt-ffplay" "${CURRENT_PACKAGES_DIR}/debug/bin/srt-ffplay")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/srt/srt.h" "#ifdef SRT_DYNAMIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
