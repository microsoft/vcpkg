
set(NVML_VERSION 1.3)
set(NVML_HASH 59fb552c693d5279ec86eff8eb1c36832c9c5beb6492a64b54b21c09d90ed52cba22d57912a304cf1ec17c4633da641200fd50dbe4a38355f43c674842f991bd)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${NVML_VERSION})

include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "WARNING: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    message(FATAL_ERROR "x86 is not supported. Please use nvml:x64-windows or set environment variable VCPKG_DEFAULT_TRIPLET to 'x64-windows'")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# Download source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/nvml
    REF ${NVML_VERSION}
    SHA512 ${NVML_HASH}
    HEAD_REF master
)

# Build only the selected projects
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/src/NVML.sln
    PLATFORM x64
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmempool,Solution Items\\libvmem,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${NVML_VERSION}
)

set(DEBUG_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Debug)
set(RELEASE_ARTIFACTS_PATH ${SOURCE_PATH}/src/x64/Release)

# Install header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/libpmemobj/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libpmemobj)
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/libpmemobj++/*.hpp)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libpmemobj++)
# Remove unneeded header files
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/libvmmalloc.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/librpmem.h)
    
# Install libraries (debug)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/lib[pv]mem*.lib ${DEBUG_ARTIFACTS_PATH}/lib[pv]mem*.exp)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libpmemcommon.lib)
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/lib[pv]mem*.dll)
file(INSTALL ${LIB_DEBUG_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# Install libraries (release)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/lib[pv]mem*.lib ${RELEASE_ARTIFACTS_PATH}/lib[pv]mem*.exp)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libpmemcommon.lib)
file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/lib[pv]mem*.dll)
file(INSTALL ${LIB_RELEASE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Install tools (release only)
file(INSTALL ${RELEASE_ARTIFACTS_PATH}/pmempool.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/nvml)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/nvml)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nvml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nvml/LICENSE ${CURRENT_PACKAGES_DIR}/share/nvml/copyright)
