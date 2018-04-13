if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "TBB does not currently support static crt linkage")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 01org/tbb
    REF 633b01ad27e012e1dc4e392c3230250d1f4967a4
    SHA512 5576b5e1efa0c7938dc08a1a9503ea19234b20f6a742f3d13a8de19b47f5bdafa1bb855e4de022a4b096a429e66739599a198fdf687c167c659f7556235fa01f
    HEAD_REF tbb_2018)

if(TRIPLET_SYSTEM_ARCH STREQUAL x86)
	set(BUILD_ARCH Win32)
else()
	set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

set(TBB_MSBUILD_PROJECT_DIR ${SOURCE_PATH}/build/vs2013)

vcpkg_build_msbuild(PROJECT_PATH ${TBB_MSBUILD_PROJECT_DIR}/makefile.sln PLATFORM ${BUILD_ARCH})

# Installation
message(STATUS "Installing")
file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

set(DEBUG_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/${BUILD_ARCH}/Debug)
set(RELEASE_OUTPUT_PATH ${TBB_MSBUILD_PROJECT_DIR}/${BUILD_ARCH}/Release)

file(COPY
  ${RELEASE_OUTPUT_PATH}/tbb.lib
  ${RELEASE_OUTPUT_PATH}/tbbmalloc.lib
  ${RELEASE_OUTPUT_PATH}/tbbmalloc_proxy.lib
  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY
  ${DEBUG_OUTPUT_PATH}/tbb_debug.lib
  ${DEBUG_OUTPUT_PATH}/tbbmalloc_debug.lib
  ${DEBUG_OUTPUT_PATH}/tbbmalloc_proxy_debug.lib
  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY
  ${RELEASE_OUTPUT_PATH}/tbb.dll
  ${RELEASE_OUTPUT_PATH}/tbbmalloc.dll
  ${RELEASE_OUTPUT_PATH}/tbbmalloc_proxy.dll
  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY
  ${DEBUG_OUTPUT_PATH}/tbb_debug.dll
  ${DEBUG_OUTPUT_PATH}/tbbmalloc_debug.dll
  ${DEBUG_OUTPUT_PATH}/tbbmalloc_proxy_debug.dll
  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_copy_pdbs()

include(${SOURCE_PATH}/cmake/TBBMakeConfig.cmake)
tbb_make_config(TBB_ROOT ${CURRENT_PACKAGES_DIR}
    CONFIG_DIR TBB_CONFIG_DIR # is set to ${CURRENT_PACKAGES_DIR}/cmake
    SYSTEM_NAME "Windows"
    CONFIG_FOR_SOURCE
    TBB_RELEASE_DIR "\${_tbb_root}/bin"
    TBB_DEBUG_DIR "\${_tbb_root}/debug/bin")

file(COPY ${TBB_CONFIG_DIR}/TBBConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(COPY ${TBB_CONFIG_DIR}/TBBConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(REMOVE_RECURSE ${TBB_CONFIG_DIR})

# make it work with our installation layout
file(READ ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake TBB_CONFIG_CMAKE)
string(REPLACE
"get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)"
"get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)
get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
string(REPLACE
"\${_tbb_root}/bin/\${_tbb_component}.lib"
"\${_tbb_root}/lib/\${_tbb_component}.lib" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
string(REPLACE
"\${_tbb_root}/debug/bin/\${_tbb_component}_debug.lib"
"\${_tbb_root}/debug/lib/\${_tbb_component}_debug.lib" TBB_CONFIG_CMAKE "${TBB_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake "${TBB_CONFIG_CMAKE}")

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)
