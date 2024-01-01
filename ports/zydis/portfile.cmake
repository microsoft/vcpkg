vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zydis
    REF "v${VERSION}"
    SHA512 334284bccfb6ce61cc530fd479d6278db3e4df1fb52b311acd7d21558843c9bf14e74a199cd937041d434260b65c506c07ae1a37243d2240eb9443ae5e56e000
    HEAD_REF master
    PATCHES
        zycore.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYDIS_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZYDIS_BUILD_SHARED_LIB=${ZYDIS_BUILD_SHARED_LIB}
        -DZYDIS_BUILD_EXAMPLES=OFF
    OPTIONS_DEBUG
        -DZYDIS_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zydis)

vcpkg_copy_tools(TOOL_NAMES ZydisDisasm ZydisInfo AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Zydis/Defines.h" "defined(ZYDIS_STATIC_BUILD)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
