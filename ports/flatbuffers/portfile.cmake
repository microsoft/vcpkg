vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/flatbuffers
    REF "v${VERSION}"
    SHA512 6eb5417984782208e0fcc33285d02bb13cda526d4029e0dd58e27c4f813eb39f26105ab0ed0880f7c02614985b96a241aad5086dd4f2d131c534a44a2884d08e
    HEAD_REF master
    PATCHES
        fix-uwp-build.patch
)

set(options "")
if(VCPKG_CROSSCOMPILING)
    list(APPEND options -DFLATBUFFERS_BUILD_FLATC=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF)
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
        # The option may cause "#error Unsupported architecture"
        list(APPEND options -DFLATBUFFERS_OSX_BUILD_UNIVERSAL=OFF)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLATBUFFERS_BUILD_TESTS=OFF
        -DFLATBUFFERS_BUILD_GRPCTEST=OFF
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flatbuffers)
vcpkg_fixup_pkgconfig()

file(GLOB flatc_path ${CURRENT_PACKAGES_DIR}/bin/flatc*)
if(flatc_path)
    vcpkg_copy_tools(TOOL_NAMES flatc AUTO_CLEAN)
else()
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/flatbuffers/flatbuffers-config.cmake"
"\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/share/flatbuffers/FlatcTargets.cmake\")\n")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
