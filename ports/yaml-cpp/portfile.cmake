vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbeder/yaml-cpp
    REF 9a3624205e8774953ef18f57067b3426c1c5ada6 #v0.6.3
    SHA512 9bd0f05b882beed748eddb5d615bf356b7d1f31c4e3a4bbf80a6bdeb30b33fa1e0ccf596161a489169e6a111a3112e371d8d00514a0bfd02e6a6a11513904bed
    HEAD_REF master
    PATCHES
        fix-include-path.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(YAML_BUILD_SHARED_LIBS ON)
else()
    set(YAML_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DYAML_CPP_BUILD_TOOLS=OFF
        -DYAML_CPP_BUILD_TESTS=OFF
        -DYAML_BUILD_SHARED_LIBS=${YAML_BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/yaml-cpp)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/yaml-cpp)
endif()

# Remove debug include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h DLL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 1" DLL_H "${DLL_H}")
else()
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 0" DLL_H "${DLL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h "${DLL_H}")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
