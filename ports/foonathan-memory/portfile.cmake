# WINDOWS_EXPORT_ALL_SYMBOLS doesn't work.
# unresolved external symbol "public: static unsigned int const foonathan::memory::detail::memory_block_stack::implementation_offset
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    REMOVE_TOOL_STATIC_LINKING_CROSS_COMPILATION_PATCH
    URLS https://github.com/foonathan/memory/commit/abb0bff7a232572b1fce304dd2e2a2d5c0a6806c.patch?full_index=1
    FILENAME foonathan-memory-abb0bff7a232572b1fce304dd2e2a2d5c0a6806c.patch
    SHA512 9f16c9465a6475771241470925f34ead2281c5e2f7d9c4ddaceab77fa3775b8a63ccb6dde00061d74924f838a6d204ab70427f9ae5369245b5e9e971472e862f
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/memory
    REF "v0.7-3"
    SHA512 302a046e204d1cd396a4a36b559d3360d17801d99f0f22b58314ff66706ae86ce4f364731004c1c293e01567a9510229cda7fc4978e0e47740176026d47e8403
    HEAD_REF master
    PATCHES
        fix-foonathan-memory-include-install-dir.patch
        "${REMOVE_TOOL_STATIC_LINKING_CROSS_COMPILATION_PATCH}"
)

vcpkg_from_github(
    OUT_SOURCE_PATH COMP_SOURCE_PATH
    REPO foonathan/compatibility
    REF cd142129e30f5b3e6c6d96310daf94242c0b03bf
    SHA512 1d144f82ec46dcc546ee292846330d39536a3145e5a5d8065bda545f55699aeb9a4ef7dea5e5f684ce2327fad210488fe6bb4ba7f84ceac867ac1c72b90c6d69
    HEAD_REF master
)

file(COPY "${COMP_SOURCE_PATH}/comp_base.cmake" DESTINATION "${SOURCE_PATH}/cmake/comp")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    tool FOONATHAN_MEMORY_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF
        -DFOONATHAN_MEMORY_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/foonathan_memory/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/foonathan_memory/cmake PACKAGE_NAME foonathan_memory)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/foonathan_memory/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/foonathan_memory/cmake PACKAGE_NAME foonathan_memory)
endif()

vcpkg_copy_pdbs()

# Place header files into the right folders
# The original layout is not a problem for CMake-based project.
file(COPY
    ${COMP_INCLUDE_FILES}
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/foonathan"
)
file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/lib/foonathan_memory" 
  "${CURRENT_PACKAGES_DIR}/debug/lib/foonathan_memory"
)
# Place header files into the right folders - Done!

# The Debug version of this lib is built with:
# #define FOONATHAN_MEMORY_DEBUG_FILL 1
# and Release version is built with:
# #define FOONATHAN_MEMORY_DEBUG_FILL 0
# We only have the Release version header files installed, however.
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/foonathan/memory/detail/debug_helpers.hpp"
    "#if FOONATHAN_MEMORY_DEBUG_FILL"
    "#ifndef NDEBUG //#if FOONATHAN_MEMORY_DEBUG_FILL"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README.md"
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR 
   VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX}")
    file(COPY
        "${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin"
        )
    else()
        file(REMOVE
            "${CURRENT_PACKAGES_DIR}/bin/nodesize_dbg${EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/bin/nodesize_dbg${EXECUTABLE_SUFFIX}"
        )
    endif()
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
