vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbeder/yaml-cpp
    REF 0579ae3d976091d7d664aa9d2527e0d0cff25763 # yaml-cpp-0.7.0
    SHA512 930f13737c23faf06be3fa9821492d6c677359e532212ced495173367a8aec45f87fbf3a5da47d4d1b61a95c25e0101bc7f8d175752434c63b25e097186e1745
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(YAML_BUILD_SHARED_LIBS ON)
else()
    set(YAML_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYAML_CPP_BUILD_TOOLS=OFF
        -DYAML_CPP_BUILD_TESTS=OFF
        -DYAML_BUILD_SHARED_LIBS=${YAML_BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/yaml-cpp")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/yaml-cpp)
endif()

# Remove debug include files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h" DLL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 1" DLL_H "${DLL_H}")
else()
    string(REPLACE "#ifdef YAML_CPP_DLL" "#if 0" DLL_H "${DLL_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/yaml-cpp/dll.h" "${DLL_H}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
