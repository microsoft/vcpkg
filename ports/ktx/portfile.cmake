vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/KTX-Software
    REF "v${VERSION}"
    SHA512 07c8564e1db57fea44ed565b1bc7d93ec82c29d1aa525cea0c1b1b42a8a587de0ab61b29e2c179fed4edd7cd539d13ee0112ce35728f3fe7e751de8640c679d2
    HEAD_REF master
    PATCHES
        0001-Use-vcpkg-zstd.patch
        0003-mkversion.patch
        0004-quirks.patch
        0005-no-vendored-libs.patch
        0006-fix-ios-install.patch
)
file(REMOVE "${SOURCE_PATH}/other_include/zstd_errors.h")
file(REMOVE_RECURSE "${SOURCE_PATH}/external/basisu/zstd")
file(REMOVE_RECURSE "${SOURCE_PATH}/lib/basisu/zstd")

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT
        PACKAGES
            bash
        DIRECT_PACKAGES
            # Required for "getopt"
            "https://repo.msys2.org/msys/x86_64/util-linux-2.40.2-2-x86_64.pkg.tar.zst"
            bf45b16cd470f8d82a9fe03842a09da2e6c60393c11f4be0bab354655072c7a461afc015b9c07f9f5c87a0e382cd867e4f079ede0d42f1589aa99ebbb3f76309
            # Required for "dos2unix"
            "https://mirror.msys2.org/msys/x86_64/dos2unix-7.5.2-1-x86_64.pkg.tar.zst"
            e5e949f01b19c82630131e338a4642da75e42f84220f5af4a97a11dd618e363396567b233d2adab79e05422660a0000abcbbabcd17efcadf37f07fe7565f041e
    )
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    vcpkg_list(APPEND OPTIONS "-DBASH_EXECUTABLE=${MSYS_ROOT}/usr/bin/bash.exe")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   KTX_FEATURE_TOOLS
        vulkan  KTX_FEATURE_VK_UPLOAD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKTX_VERSION_FULL=v${VERSION}
        -DKTX_FEATURE_TESTS=OFF
        -DKTX_FEATURE_LOADTEST_APPS=OFF
        -DBUILD_SHARED_LIBS=${ENABLE_SHARED}
        ${FEATURE_OPTIONS}
        ${OPTIONS}
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

if(tools IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            ktx
            toktx
            ktxsc
            ktxinfo
            ktx2ktx2
            ktx2check
        AUTO_CLEAN
    )
else()
    vcpkg_copy_pdbs()
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ktx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
file(COPY ${LICENSE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSES")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
