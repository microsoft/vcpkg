if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aeron-io/aeron
    REF "${VERSION}"
    SHA512 936b3a0d6903cc54246c41b946c8964b5f2957b115364445302764a579bbcc6d3c569c924aa44f96db309c0a90cef06779b608c6fc35c8284a041ff4d266f9db
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

# Set CRT linkage for Windows static builds
set(AERON_CMAKE_OPTIONS
    -DAERON_INSTALL_TARGETS=ON
    -DAERON_TESTS=OFF
    -DAERON_BUILD_SAMPLES=OFF
    -DBUILD_AERON_ARCHIVE_API=${BUILD_ARCHIVE}
)

# Only set static CRT if triplet explicitly requests it (VCPKG_CRT_LINKAGE=static)
# Otherwise, respect the triplet's CRT setting (dynamic/MD or static/MT)
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND AERON_CMAKE_OPTIONS
        -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$$<$$<CONFIG:Debug>:Debug>
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${AERON_CMAKE_OPTIONS}
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
