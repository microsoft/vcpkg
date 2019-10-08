include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF 05c766a1f4615ee37d37d09271aaabca30ffd293
    SHA512 329697e8e23d619313440d57ef740a94c49d13533e1b8734fc8ff72fd5092c2addabb306f64cb69160fa5fee373a05ba39a5ee6d92d95e5e2e9c7ec96a51aadc
    HEAD_REF master
    PATCHES 
    	"disable-update-version.patch"
        "fix-install.patch"
        "export-target-config.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/third_party/glslang)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_spirv.txt DESTINATION ${SOURCE_PATH}/third_party/spirv-tools)
file(RENAME ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists_spirv.txt ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists.txt)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/build-version.inc DESTINATION ${SOURCE_PATH}/glslc/src)

#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
set(VCPKG_LIBRARY_LINKAGE "static")
set(OPTIONS)
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DSHADERC_ENABLE_SHARED_CRT=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

if("combine" IN_LIST FEATURES)
    list(APPEND OPTIONS -DSHADERC_ENABLE_COMBINE=ON)
else()
    list(APPEND OPTIONS -DSHADERC_ENABLE_COMBINE=OFF)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSHADERC_SKIP_TESTS=true ${OPTIONS} -Dglslang_SOURCE_DIR=${CURRENT_INSTALLED_DIR}/include -Dspirv-tools_SOURCE_DIR=${CURRENT_INSTALLED_DIR}/include 
    OPTIONS_DEBUG -DSUFFIX_D=true
    OPTIONS_RELEASE -DSUFFIX_D=false
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/shaderc)

file(READ ${CURRENT_PACKAGES_DIR}/share/shaderc/shadercConfig.cmake shaderc_config_file)

if("combine" IN_LIST FEATURES)
    string(REPLACE 
        [[
# Cleanup temporary variables.
set(_IMPORT_PREFIX)]]
        [[
# add target shaderc::shaderc_combined
set(_COMBINED_LIB "shaderc_combined.lib")
if (UNIX)
  set(_COMBINED_LIB "libshaderc_combined.a")
endif()
add_library(shaderc::shaderc_combined STATIC IMPORTED)
set_target_properties(shaderc::shaderc_combined PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
)

set_property(TARGET shaderc::shaderc_combined APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(shaderc::shaderc_combined PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/${_COMBINED_LIB}"
)

set_property(TARGET shaderc::shaderc_combined APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(shaderc::shaderc_combined PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib/${_COMBINED_LIB}"
)

# Cleanup temporary variables.
set(_COMBINED_LIB)
set(_IMPORT_PREFIX)]] 
    shaderc_config_file "${shaderc_config_file}")

endif("combine" IN_LIST FEATURES)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/shaderc/shadercConfig.cmake [[
# Depend packages
if(NOT glslang_FOUND)
  find_package(glslang)
endif()
if(NOT spirv-tools_FOUND)
  find_package(spirv-tools)
endif()
]])
file(APPEND ${CURRENT_PACKAGES_DIR}/share/shaderc/shadercConfig.cmake "${shaderc_config_file}")


file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*${CMAKE_EXECUTABLE_SUFFIX}")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

#Safe to remove as libs are static
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shaderc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shaderc/LICENSE ${CURRENT_PACKAGES_DIR}/share/shaderc/copyright)
