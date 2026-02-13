if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aeron-io/aeron
    REF "${VERSION}"
    SHA512 9d2e862eb8b5c17716d8c913640271d932ebc7129f000d58266b4144b20da502abaad45c603b37ed4ddfff8a12cb0f7d41d4631148fb7ca28f1bbdcead95bd42
    HEAD_REF master
    PATCHES
        patches/add-libuuid-vcpkg-support.patch
        patches/fix-static-crt-linkage.patch
)

# Set archive option based on feature
if("archive" IN_LIST FEATURES)
    set(BUILD_ARCHIVE ON)
else()
    set(BUILD_ARCHIVE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAERON_INSTALL_TARGETS=ON
        -DAERON_TESTS=OFF
        -DAERON_BUILD_SAMPLES=OFF
        -DBUILD_AERON_ARCHIVE_API=${BUILD_ARCHIVE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/aeron)

# Aeron always builds both static and shared libraries regardless of VCPKG_LIBRARY_LINKAGE.
# Handle the shared library artifacts based on linkage type.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # For static builds, remove shared library artifacts (DLLs, SOs, DYLIBs and their import libs)
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/lib/aeron.dll"
        "${CURRENT_PACKAGES_DIR}/lib/aeron_client_shared.dll"
        "${CURRENT_PACKAGES_DIR}/lib/aeron_driver.dll"
        "${CURRENT_PACKAGES_DIR}/lib/aeron.lib"
        "${CURRENT_PACKAGES_DIR}/lib/aeron_client_shared.lib"
        "${CURRENT_PACKAGES_DIR}/lib/aeron_driver.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron.dll"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron_client_shared.dll"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron_driver.dll"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron_client_shared.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/aeron_driver.lib"
    )
else()
    # For dynamic builds, move DLLs from lib to bin
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    file(GLOB DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    if(RELEASE_DLLS)
        file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE ${RELEASE_DLLS})
    endif()
    if(DEBUG_DLLS)
        file(COPY ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE ${DEBUG_DLLS})
    endif()
endif()

# Copy aeronmd tools
vcpkg_copy_tools(TOOL_NAMES aeronmd aeronmd_s AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
