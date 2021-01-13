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

if (NOT(WIN32) AND ${YAML_BUILD_SHARED_LIBS})
    vcpkg_download_distfile(patchForLinux
        URLS https://github.com/jbeder/yaml-cpp/pull/958.patch
        FILENAME jbeder_yaml-cpp_958.patch
        SHA512 3f32a6a84f0003c5479458bc987d8385eb3efb79b67b4c012eec6bb2b8f79d4acc6c24cf4e9c4cfa449ea807c864e96d6aeb3b4994bc7dae0cfb0760e791927f)
    vcpkg_apply_patches(
       SOURCE_PATH ${SOURCE_PATH}
       PATCHES ${patchForLinux})
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
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 1" DLL_H "${DLL_H}")
else()
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 0" DLL_H "${DLL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h "${DLL_H}")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
