vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/ncnn
    REF "${VERSION}"
    SHA512 31bc3c2f461a00241fb8f69ca6ea8cc590af6618856b1b84a048bde924e4b474fd883ad5d54dbfbdd1e5b59015889e15ffc4fbafccb3e42e052a02071f2017b1
    HEAD_REF master
    PATCHES
        fix_uwp.patch #https://github.com/Tencent/ncnn/pull/5328
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan NCNN_VULKAN
        vulkan NCNN_SYSTEM_GLSLANG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNCNN_BUILD_TOOLS=OFF
        -DNCNN_BUILD_EXAMPLES=OFF
        -DNCNN_BUILD_BENCHMARK=OFF
        -DNCNN_SHARED_LIB=${BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ncnn)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
