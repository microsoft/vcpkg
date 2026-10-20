vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/ncnn
    REF "${VERSION}"
    SHA512 f49f5990cf6269fb67ea5aa766949eb27c961d7403276fe1f0ddef108584ff1c8c25c54266737b0d1ed7793c79eb4a37b14add05ed6594ca814a23160d6989cc
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan NCNN_VULKAN
        vulkan NCNN_SYSTEM_GLSLANG
)

if(vulkan IN_LIST FEATURES AND VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DNCNN_SIMPLEVK=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNCNN_BUILD_TOOLS=OFF
        -DNCNN_BUILD_EXAMPLES=OFF
        -DNCNN_BUILD_BENCHMARK=OFF
        -DNCNN_SHARED_LIB=${BUILD_SHARED}
        -DNCNN_VERSION=${VERSION}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ncnn)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
