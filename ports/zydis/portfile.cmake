
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zydis
    REF "v${VERSION}"
    SHA512 e07add4d43768ded02a238911fde6e74d2391abf8df282f774fca1a8c3fca3e97b03e90e0f3c7c0f3c75485fb29c0be4071d5e5b2e23dd5b8b1a864e3b713fbc
    HEAD_REF master
    PATCHES
        zycore.patch

)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYDIS_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZYAN_SYSTEM_ZYCORE=ON
        -DZYDIS_BUILD_SHARED_LIB=${ZYDIS_BUILD_SHARED_LIB}
        -DZYDIS_BUILD_DOXYGEN=OFF
        -DZYDIS_BUILD_EXAMPLES=OFF
        -DZYDIS_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DZYDIS_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zydis)

vcpkg_copy_tools(TOOL_NAMES ZydisDisasm ZydisInfo AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Zydis/Defines.h" "defined(ZYDIS_STATIC_BUILD)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
