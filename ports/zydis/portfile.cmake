vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zydis
    REF 5488b7caba739a89febe3b1a83cc86d6ec136cbb #v4.0.0
    SHA512 8219c394f440580fa721aa1ebdb69eb38950d5bd7edf8839457c240076d28a94ac0d7132275b2913229c9529dd5451b9a7987c4b5799de0c34a23ee2dbf164e6
    HEAD_REF master
    PATCHES
        zycore.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYDIS_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DZYDIS_BUILD_SHARED_LIB=${ZYDIS_BUILD_SHARED_LIB}"
        -DZYDIS_BUILD_EXAMPLES=OFF
    OPTIONS_DEBUG
        -DZYDIS_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME Zycore CONFIG_PATH lib/cmake/zydis)

vcpkg_copy_tools(TOOL_NAMES ZydisDisasm ZydisInfo AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
