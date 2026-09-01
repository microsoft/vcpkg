vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF vulkan-sdk-${VERSION}
    SHA512 b02d43382fec30ff4f594794d153918eb1fd9b3329603fbffab0249e29c60c1364d2607317d7a2c6c2c0a61871d669166c4395bace288595ef4e472badaebfd2
    HEAD_REF master
)

if(VCPKG_TARGET_IS_IOS)
    message(STATUS "Using iOS triplet. Executables won't be created...")
    set(BUILD_CLI OFF)
else()
    set(BUILD_CLI ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
        -DSPIRV_CROSS_CLI=${BUILD_CLI}
        -DSPIRV_CROSS_SKIP_INSTALL=OFF
        -DSPIRV_CROSS_ENABLE_C_API=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/spirv-cross-c.pc" "-lspirv-cross-c" "-lspirv-cross-cd")
    endif()
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/spirv-cross-c.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig()

foreach(COMPONENT core c cpp glsl hlsl msl reflect util)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/spirv_cross_${COMPONENT}/cmake PACKAGE_NAME spirv_cross_${COMPONENT})
endforeach()

if(BUILD_CLI)
    vcpkg_copy_tools(TOOL_NAMES spirv-cross AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
