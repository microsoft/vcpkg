vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/LLGI
    REF e518022a9d0766ac6b276ca5143778653a3f3ca3
    SHA512 3b797033724124cac379898a1e51f066e360d7428a03c203908a14459fb83df6c6a08e02fd9b752a647203ad8b2d5573e27e8a4f53e277938ba1f33d6d3da549
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan      BUILD_VULKAN
        vulkan      BUILD_VULKAN_COMPILER
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" USE_RUNTIME_MD)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TEST=OFF
        -DBUILD_TOOL=OFF
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=${USE_RUNTIME_MD}
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
