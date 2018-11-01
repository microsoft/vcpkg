include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Static CRT linkage is not supported")
endif()

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    message(FATAL_ERROR "x86 is not supported. Please use pmdk:x64-windows instead.")
endif()

# Download source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk
    REF 1.4.2
    SHA512 87aa226487046aba14f3a0b51d066f4498a6021580fd203df45f0900fc0c0c5cdb192156a4c730a5a7dc5826e204d688531e5680145161750057803cb24d088d
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/addPowerShellExecutionPolicy.patch"
        "${CMAKE_CURRENT_LIST_DIR}/v141.patch"
)

get_filename_component(PMDK_VERSION "${SOURCE_PATH}" NAME)
string(REPLACE "pmdk-" "" PMDK_VERSION "${PMDK_VERSION}")

# Build only the selected projects
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/src/PMDK.sln
    TARGET "Solution Items\\libpmem,Solution Items\\libpmemlog,Solution Items\\libpmemblk,Solution Items\\libpmemobj,Solution Items\\libpmemcto,Solution Items\\libpmempool,Solution Items\\libvmem,Solution Items\\Tools\\pmempool"
    OPTIONS /p:SRCVERSION=${PMDK_VERSION}
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
file(INSTALL ${RELEASE_ARTIFACTS_PATH}/pmempool.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/pmdk)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/pmdk)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pmdk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pmdk/LICENSE ${CURRENT_PACKAGES_DIR}/share/pmdk/copyright)
