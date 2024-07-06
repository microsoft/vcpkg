vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF "v${VERSION}"
    SHA512 ce81add9d978a6b63d4205715eac5084e81a6753da1f6c6bad6493e60253215901bffc4a60d704a873333f2b9f94fd86cb7eb5b293035f2268c12692bd808bac
    HEAD_REF main
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        codegen VCPKG_UPB_BUILD_CODEGEN
)

if(NOT VCPKG_UPB_BUILD_CODEGEN)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" "${CURRENT_HOST_INSTALLED_DIR}/tools/upb")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/upb/cmake"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup()

if (VCPKG_UPB_BUILD_CODEGEN)
    vcpkg_copy_tools(
        AUTO_CLEAN
        TOOL_NAMES
            protoc-gen-upbdefs
            protoc-gen-upb
            protoc-gen-upb_minitable
    )
else()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/upb-config-vcpkg-tools.cmake" "${CURRENT_PACKAGES_DIR}/share/upb/upb-config-vcpkg-tools.cmake" @ONLY)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
