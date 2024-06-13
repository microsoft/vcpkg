vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Haivision/srt
    REF "v${VERSION}"
    SHA512 5b576d6fd325515e05074e4568e3b65d1ae265e3e971db6e6242e5138243fc1594df1e3a7d90962385dac38abc34c4c4b0a567439050f8c0ff818b3b3d497efc
    HEAD_REF master
    PATCHES
        fix-static.patch
        pkgconfig.diff
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
    if(NOT MINGW)
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
