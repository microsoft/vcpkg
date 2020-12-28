vcpkg_fail_port_install(ON_TARGET "UWP")

set(PORT_VERSION 4.0.0-beta5)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/KTX-Software
    REF v${PORT_VERSION}
    SHA512 8c63be2a7c55b8fdb8c8aee1f7cacdc2105e54061691c69cddbd3bed49f8e907262cc3ae83dfd723e76f0911bd6c85f5bbc19347998988a1fc6ecae26bfecf33
    HEAD_REF master
    PATCHES
        0001-Use-vcpkg-zstd.patch
        0002-Fix-versioning.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools KTX_FEATURE_TOOLS
    vulkan KTX_FEATURE_VULKAN
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DKTX_VERSION_FULL=v${PORT_VERSION}
        -DKTX_FEATURE_TESTS=OFF
        -DKTX_FEATURE_LOADTEST_APPS=OFF
        -DKTX_FEATURE_STATIC_LIBRARY=${ENABLE_STATIC}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(tools IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            toktx
            ktxsc
            ktxinfo
            ktx2ktx2
            ktx2check
        AUTO_CLEAN
    )
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ktx TARGET_PATH share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
file(COPY ${LICENSE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSES")