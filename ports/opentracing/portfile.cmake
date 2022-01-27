if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LOCAL_OPTIONS
        -DBUILD_STATIC_LIBS=OFF
    )
else()
    message("Static building is only possible when compiling static and dynamic versions at the same time. Enabling both.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opentracing/opentracing-cpp
    REF 4bb431f7728eaf383a07e86f9754a5b67575dab0 # v1.6.0
    SHA512 1c69ff4cfd5f6037a48815367d3026c1bf06c3c49ebf232a64c43167385fb62e444c3b3224fc38f68ef0fdb378e3736db6ee6ba57160e6e578c87c09e92e527e
    PATCHES
        repair_mojibake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DENABLE_LINTING=OFF
        ${LOCAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenTracing)

vcpkg_copy_pdbs()

# Move DLLs to /bin
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/opentracing.dll ${CURRENT_PACKAGES_DIR}/bin/opentracing.dll)

        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/opentracing.dll ${CURRENT_PACKAGES_DIR}/debug/bin/opentracing.dll)

        # Fix targets
        file(READ ${CURRENT_PACKAGES_DIR}/share/opentracing/OpenTracingTargets-release.cmake RELEASE_CONFIG)
        string(REPLACE "\${_IMPORT_PREFIX}/lib/opentracing.dll"
                "\${_IMPORT_PREFIX}/bin/opentracing.dll" RELEASE_CONFIG ${RELEASE_CONFIG})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opentracing/OpenTracingTargets-release.cmake "${RELEASE_CONFIG}")

        file(READ ${CURRENT_PACKAGES_DIR}/share/opentracing/OpenTracingTargets-debug.cmake DEBUG_CONFIG)
        string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/opentracing.dll"
                "\${_IMPORT_PREFIX}/debug/bin/opentracing.dll" DEBUG_CONFIG ${DEBUG_CONFIG})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opentracing/OpenTracingTargets-debug.cmake "${DEBUG_CONFIG}")
    endif()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Remove duplicate headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
