# WINDOWS_EXPORT_ALL_SYMBOLS doesn't work.
# unresolved external symbol "public: static unsigned int const foonathan::memory::detail::memory_block_stack::implementation_offset
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/memory
    REF 0f0775770fd1c506fa9c5ad566bd6ba59659db66
    SHA512 cea17694971de46ae2f680a300fdf1921a6999f7c6c991c0905940880f751ac5ae296fd7b349d0080f31e5eb5b4c3ca0b0616a29525db7b22e4f3b41a47d4796
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH COMP_SOURCE_PATH
    REPO foonathan/compatibility
    REF cd142129e30f5b3e6c6d96310daf94242c0b03bf
    SHA512 1d144f82ec46dcc546ee292846330d39536a3145e5a5d8065bda545f55699aeb9a4ef7dea5e5f684ce2327fad210488fe6bb4ba7f84ceac867ac1c72b90c6d69
    HEAD_REF master
)

file(COPY ${COMP_SOURCE_PATH}/comp_base.cmake DESTINATION ${SOURCE_PATH}/cmake/comp)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES tool FOONATHAN_MEMORY_BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF
        -DFOONATHAN_MEMORY_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/foonathan_memory)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/foonathan_memory/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/foonathan_memory/cmake TARGET_PATH share/foonathan_memory)
endif()

vcpkg_copy_pdbs()

# Place header files into the right folders
# The original layout is not a problem for CMake-based project.
file(COPY
    ${CURRENT_PACKAGES_DIR}/include/foonathan_memory/foonathan
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(GLOB
    COMP_INCLUDE_FILES
    ${CURRENT_PACKAGES_DIR}/include/foonathan_memory/comp/foonathan/*.hpp
)
file(COPY
    ${COMP_INCLUDE_FILES}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/foonathan
)
# Commenting below since this file does not exist in the new version.
#file(COPY
#    ${CURRENT_PACKAGES_DIR}/include/foonathan_memory/config_impl.hpp
#    DESTINATION ${CURRENT_PACKAGES_DIR}/include/foonathan/memory
#)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/foonathan_memory
)
# Commenting below since this file does not exist in the new version.
#vcpkg_replace_string(
#    ${CURRENT_PACKAGES_DIR}/share/foonathan_memory/foonathan_memory-config.cmake
#    "\${_IMPORT_PREFIX}/include/foonathan_memory/comp;\${_IMPORT_PREFIX}/include/foonathan_memory"
#    "\${_IMPORT_PREFIX}/include"
#)
# Place header files into the right folders - Done!

# The Debug version of this lib is built with:
# #define FOONATHAN_MEMORY_DEBUG_FILL 1
# and Release version is built with:
# #define FOONATHAN_MEMORY_DEBUG_FILL 0
# We only have the Release version header files installed, however.
vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/include/foonathan/memory/detail/debug_helpers.hpp
    "#if FOONATHAN_MEMORY_DEBUG_FILL"
    "#ifndef NDEBUG //#if FOONATHAN_MEMORY_DEBUG_FILL"
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/LICENSE
    ${CURRENT_PACKAGES_DIR}/README.md
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR 
   VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX})
    file(COPY
        ${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
    )
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE
            ${CURRENT_PACKAGES_DIR}/bin
            ${CURRENT_PACKAGES_DIR}/debug/bin
        )
    else()
        file(REMOVE
            ${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/nodesize_dbg${EXECUTABLE_SUFFIX}
        )
    endif()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
