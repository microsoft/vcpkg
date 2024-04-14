
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v${VERSION}
    SHA512 da7710c6dfaa90970c223a503702fc7c7dd86c1397372b3d6f51c4377d28d8e62b90ee8c99b70e3aa49e16971a5789bb8f588ea924881b9dd5dd8d5fcd16518a
    HEAD_REF master
    PATCHES
        001-no-runtime-install.patch
        002-fix-when-embree3-has-been-installed.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static EMBREE_STATIC_LIB)
string(COMPARE EQUAL ${VCPKG_CRT_LINKAGE} static EMBREE_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        backface-culling                        EMBREE_BACKFACE_CULLING
        backface-culling-curves                 EMBREE_BACKFACE_CULLING_CURVES
        backface-culling-spheres                EMBREE_BACKFACE_CULLING_SPHERES
        compact-polys                           EMBREE_COMPACT_POLYS
        disc-point-self-intersection-avoidance  EMBREE_DISC_POINT_SELF_INTERSECTION_AVOIDANCE
        filter-function                         EMBREE_FILTER_FUNCTION
        ignore-invalid-rays                     EMBREE_IGNORE_INVALID_RAYS
        ray-mask                                EMBREE_RAY_MASK
        ray-packets                             EMBREE_RAY_PACKETS

        geometry-triangle           EMBREE_GEOMETRY_TRIANGLE
        geometry-quad               EMBREE_GEOMETRY_QUAD
        geometry-curve              EMBREE_GEOMETRY_CURVE
        geometry-subdivision        EMBREE_GEOMETRY_SUBDIVISION
        geometry-user               EMBREE_GEOMETRY_USER
        geometry-instance           EMBREE_GEOMETRY_INSTANCE
        geometry-instance-array     EMBREE_GEOMETRY_INSTANCE_ARRAY
        geometry-grid               EMBREE_GEOMETRY_GRID
        geometry-point              EMBREE_GEOMETRY_POINT
)

# Automatically select best ISA based on platform or VCPKG_CMAKE_CONFIGURE_OPTIONS.
vcpkg_list(SET EXTRA_OPTIONS)
if(VCPKG_TARGET_IS_EMSCRIPTEN)
    # Disable incorrect ISA set for Emscripten and enable NEON which is supported and should provide decent performance.
    # cf. [Using SIMD with WebAssembly](https://emscripten.org/docs/porting/simd.html#using-simd-with-webassembly)
    vcpkg_list(APPEND EXTRA_OPTIONS
        -DEMBREE_MAX_ISA:STRING=NONE

        -DEMBREE_ISA_AVX:BOOL=OFF
        -DEMBREE_ISA_AVX2:BOOL=OFF
        -DEMBREE_ISA_AVX512:BOOL=OFF
        -DEMBREE_ISA_SSE2:BOOL=OFF
        -DEMBREE_ISA_SSE42:BOOL=OFF
        -DEMBREE_ISA_NEON:BOOL=ON
    )
elseif(VCPKG_TARGET_IS_OSX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
    # The best ISA for Apple arm64 is unique and unambiguous.
    vcpkg_list(APPEND EXTRA_OPTIONS
        -DEMBREE_MAX_ISA:STRING=NONE
    )
elseif(VCPKG_TARGET_IS_OSX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") AND (VCPKG_LIBRARY_LINKAGE STREQUAL "static"))
    # AppleClang >= 9.0 does not support selecting multiple ISAs.
    # Let Embree select the best and unique one.
    vcpkg_list(APPEND EXTRA_OPTIONS
        -DEMBREE_MAX_ISA:STRING=DEFAULT
    )
else()
    # Let Embree select the best ISA set for the targeted platform.
    vcpkg_list(APPEND EXTRA_OPTIONS
        -DEMBREE_MAX_ISA:STRING=NONE
    )
endif()

if("tasking-tbb" IN_LIST FEATURES)
    set(EMBREE_TASKING_SYSTEM "TBB")
else()
    set(EMBREE_TASKING_SYSTEM "INTERNAL")
endif()

vcpkg_replace_string("${SOURCE_PATH}/common/cmake/installTBB.cmake" "IF (EMBREE_STATIC_LIB)" "IF (0)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_SYCL_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
        -DEMBREE_TASKING_SYSTEM:STRING=${EMBREE_TASKING_SYSTEM}
        -DEMBREE_INSTALL_DEPENDENCIES=OFF
        -DEMBREE_ZIP_MODE=OFF
    MAYBE_UNUSED_VARIABLES
        EMBREE_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/embree-${VERSION} PACKAGE_NAME embree)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/embree" "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
set(config_file "${CURRENT_PACKAGES_DIR}/share/${PORT}/embree-config.cmake")
# Fix details in config.
file(READ "${config_file}" contents)
string(REPLACE "SET(EMBREE_BUILD_TYPE Release)" "" contents "${contents}")
string(REPLACE "/../../../" "/../../" contents "${contents}")
string(REPLACE "FIND_PACKAGE" "include(CMakeFindDependencyMacro)\n  find_dependency" contents "${contents}")
string(REPLACE "REQUIRED" "COMPONENTS" contents "${contents}")
string(REPLACE "/lib/cmake/embree-${VERSION}" "/share/${PORT}" contents "${contents}")
string(REPLACE "embree_sse42-targets.cmake" "embree4_sse42-targets.cmake" contents "${contents}")
string(REPLACE "embree_avx-targets.cmake" "embree4_avx-targets.cmake" contents "${contents}")
string(REPLACE "embree_avx2-targets.cmake" "embree4_avx2-targets.cmake" contents "${contents}")
string(REPLACE "embree_avx512-targets.cmake" "embree4_avx512-targets.cmake" contents "${contents}")

if(NOT VCPKG_BUILD_TYPE)
    string(REPLACE "/lib/embree4.lib" "$<$<CONFIG:DEBUG>:/debug>/lib/embree4.lib" contents "${contents}")
endif()
file(WRITE "${config_file}" "${contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
if(APPLE)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/uninstall.command" "${CURRENT_PACKAGES_DIR}/debug/uninstall.command")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc/embree4" "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")