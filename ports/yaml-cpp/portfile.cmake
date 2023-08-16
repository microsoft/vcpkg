vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbeder/yaml-cpp
    REF "${VERSION}"
    SHA512 aae9d618f906117d620d63173e95572c738db518f4ff1901a06de2117d8deeb8045f554102ca0ba4735ac0c4d060153a938ef78da3e0da3406d27b8298e5f38e
    HEAD_REF master
    PATCHES
        "yaml-cpp-pr-1212.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" YAML_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYAML_CPP_BUILD_TOOLS=OFF
        -DYAML_CPP_BUILD_TESTS=OFF
        -DYAML_BUILD_SHARED_LIBS=${YAML_BUILD_SHARED_LIBS}
        -DYAML_CPP_INSTALL_CMAKEDIR=share/${PORT}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/yaml-cpp.pc" "-lyaml-cpp" "-lyaml-cppd")
endif()
vcpkg_fixup_pkgconfig()

# Remove debug include
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h" "#ifdef YAML_CPP_STATIC_DEFINE" "#if 0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h" "#ifdef YAML_CPP_STATIC_DEFINE" "#if 1")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
