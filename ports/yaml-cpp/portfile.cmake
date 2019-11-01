vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbeder/yaml-cpp
    REF 9a3624205e8774953ef18f57067b3426c1c5ada6 # yaml-cpp-0.6.3
    SHA512 9bd0f05b882beed748eddb5d615bf356b7d1f31c4e3a4bbf80a6bdeb30b33fa1e0ccf596161a489169e6a111a3112e371d8d00514a0bfd02e6a6a11513904bed
    HEAD_REF master
    PATCHES
        0002-fix-include-path.patch
        0003-cxx-std-features.patch
		0004-fix-test.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(BUILD_SHARED ON)
else()
	set(BUILD_SHARED OFF)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL dymanic)
	set(SHARED_RT OFF)
else()
	set(SHARED_RT ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	test YAML_CPP_BUILD_TESTS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
		-DYAML_BUILD_SHARED_LIBS=${BUILD_SHARED}
		-DYAML_MSVC_SHARED_RT=${SHARED_RT}
		-DYAML_MSVC_STHREADED_RT=OFF
        -DYAML_CPP_BUILD_TOOLS=OFF
		-DYAML_CPP_INSTALL=ON
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
