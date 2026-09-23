vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miniupnp/libnatpmp
    REF 134fc89e2781e154e40042641f4d8bcbe42579f1
    SHA512 4021646ef21cd2501e92c71f261d9a5859bafb59ebb6728e372cf69383792acb0839133beff10d638d9447efeec49d87b5f39d1f5fe7ee371f1f140b3e322969
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES natpmpc AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/natpmp_declspec.h"
        "#define NATPMP_DECLSPEC_H_INCLUDED"
        "#define NATPMP_DECLSPEC_H_INCLUDED\n\n#define NATPMP_STATICLIB"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
