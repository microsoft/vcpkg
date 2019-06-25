include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP build is not supported.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set( LOCAL_OPTIONS
        -DBUILD_STATIC_LIBS=OFF
    )
else()
    message("Static building is only possible when compiling static and dynamic versions at the same time. Enabling both.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opentracing/opentracing-cpp
    REF cf9b9d5c26ef985af2213521a4f0701b7e715db2
    SHA512 75b77781c075c6814bf4a81d793e872ca47447fe82a4cad878bee99ffb2082e13e95ee285f32fb2e599765b08b4404d8e475bacff79a412a954d227b93ba53ef
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opentracing RENAME copyright)

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
