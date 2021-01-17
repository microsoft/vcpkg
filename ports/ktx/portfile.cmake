vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "x86")

set(PORT_VERSION 4.0.0-beta6)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/KTX-Software
    REF v${PORT_VERSION}
    SHA512 f70e7f3184fc5e42c48c022dd7c11a098f7b589da3fbf2bd1c6613979c8831d96d8ff1ecdb700b81ea5ddd8d13a8a0bb3bdd2470698298d0c117884ab56e982f
    HEAD_REF master
    PATCHES
        0001-Use-vcpkg-zstd.patch
        0002-Fix-versioning.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT
        PACKAGES
            bash
        DIRECT_PACKAGES
            # Required for "getopt"
            "https://repo.msys2.org/msys/x86_64/util-linux-2.35.2-1-x86_64.pkg.tar.zst"
            ff951c2cd96d0fda87bacb505c93e4aa1f9aeb35f829c52b5a7862d05e167f69605a4927a0e7197b5ee2b2fa5cb56619ad7a6ba293ede4765fdcacedf2ed35da
        )
    vcpkg_add_to_path(${MSYS_ROOT}/usr/bin)
    
    file(REMOVE
        "${SOURCE_PATH}/other_include/zstd.h"
        "${SOURCE_PATH}/other_include/zstd_errors.h")
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
file(COPY ${LICENSE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSES")