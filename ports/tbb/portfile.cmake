if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Build settings not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 01org/tbb
    REF 2017_U6
    SHA512 76b49fd085d8407b68b0f17e6eebfbcb7d2e6f9116bb5f6a00c6b4d59a55b16f9de79a2b9c9c3ece497b01810c33df21d0657893fd886db8bed639091ba97060
    HEAD_REF tbb_2017)

if(TRIPLET_SYSTEM_ARCH STREQUAL x86)
	set(BUILD_ARCH Win32)
else()
	set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(PROJECT_PATH ${SOURCE_PATH}/build/vs2012/makefile.sln PLATFORM ${BUILD_ARCH})

# Installation
message(STATUS "Installing")
file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

set(DEBUG_OUTPUT_PATH ${SOURCE_PATH}/build/vs2012/${BUILD_ARCH}/Debug)
set(RELEASE_OUTPUT_PATH ${SOURCE_PATH}/build/vs2012/${BUILD_ARCH}/Release)

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

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)
