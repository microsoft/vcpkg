vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/KTX-Software
    REF "v${VERSION}"
    SHA512 bb8f728009ba7e15eecd2d9eb7985883a6a85f4ea8fccfa7f25a5567240980d1eb8bcde67d90e56e5c93de910d1bc93704bc5cbd390a8cb660051a698d7fd573
    HEAD_REF master
    PATCHES
        0001-Use-vcpkg-zstd.patch
        0002-Fix-versioning.patch
        0003-mkversion.patch
        0004-quirks.patch
)
file(REMOVE "${SOURCE_PATH}/other_include/zstd_errors.h")

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT
        PACKAGES
            bash
        DIRECT_PACKAGES
            # Required for "getopt"
            "https://repo.msys2.org/msys/x86_64/util-linux-2.35.2-3-x86_64.pkg.tar.zst"
            da26540881cd5734072717133307e5d1a27a60468d3656885507833b80f24088c5382eaa0234b30bdd9e8484a6638b4514623f5327f10b19eed36f12158e8edb
    )
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    vcpkg_list(APPEND OPTIONS "-DBASH_EXECUTABLE=${MSYS_ROOT}/usr/bin/bash.exe")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   KTX_FEATURE_TOOLS
        vulkan  KTX_FEATURE_VULKAN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKTX_VERSION_FULL=v${VERSION}
        -DKTX_FEATURE_TESTS=OFF
        -DKTX_FEATURE_LOADTEST_APPS=OFF
        -DKTX_FEATURE_STATIC_LIBRARY=${ENABLE_STATIC}
        ${FEATURE_OPTIONS}
        ${OPTIONS}
        # Do not regenerate headers (needs more dependencies)
        -DCMAKE_DISABLE_FIND_PACKAGE_Vulkan=1
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
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
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ktx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
file(COPY ${LICENSE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSES")
