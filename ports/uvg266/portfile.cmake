vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ultravideo/uvg266 
    REF v${VERSION}
    SHA512 892b0732516fe2639f93b250bbed342da8134deeaa6f0ccb429ff8451df727f971c7ee284fef93eaa431c5c54a8b8789ffc853d8b45ae93433ba17007989bbae
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        -DBUILD_TESTS=OFF
        -DGIT_SUBMODULE=OFF
    MAYBE_UNUSED_VARIABLES GIT_SUBMODULE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/uvg266.pc" "-luvg266" "-llibuvg266")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/uvg266.pc" "-luvg266" "-llibuvg266")
endif()
vcpkg_copy_tools(TOOL_NAMES uvg266 AUTO_CLEAN)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/uvg266")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/uvg266.h"
        "#define UVG266_H_"
        "#define UVG266_H_\n#define UVG_STATIC_LIB"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE.EXT.greatest"
        "${SOURCE_PATH}/src/threadwrapper/LICENSE"
        "${SOURCE_PATH}/src/extras/getopt.h"
        "${SOURCE_PATH}/src/extras/libmd5.h"
)
