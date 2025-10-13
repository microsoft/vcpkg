vcpkg_download_distfile(OPERATOR_FIX
    URLS https://github.com/RenderKit/embree/commit/cda4cf1919bb2a748e78915fbd6e421a1056638d.diff?full_index=1
    FILENAME embree3-operator-fix-cda4cf1919bb2a748e78915fbd6e421a1056638d.diff
    SHA512 3b8492f136b8616da3c21deea32df0629c48d2e0d9b92d418c04570cb71c4c29e280b63f5447a70479ba3bcef989132ea9ccfa20793f46595554ac04f65fe3bd
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v${VERSION}
    SHA512 13ae19b1750197fb4887ba601c75d1b54b3c388224672b6561dd922bc9b9747139cf46ce554727e3afa13dcf152ce4d703935cb9105ced792b011f2d05fa3e95
    HEAD_REF master
    PATCHES
        no-runtime-install.patch
        001-downgrade-find-package-tbb-2020.patch
        avoid-library-conflicts.diff
        "${OPERATOR_FIX}"
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static EMBREE_STATIC_LIB)
string(COMPARE EQUAL ${VCPKG_CRT_LINKAGE} static EMBREE_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        backface-culling      EMBREE_BACKFACE_CULLING 
        compact-polys         EMBREE_COMPACT_POLYS   
        filter-function       EMBREE_FILTER_FUNCTION  
        ray-mask              EMBREE_RAY_MASK 
        ray-packets           EMBREE_RAY_PACKETS 

        geometry-triangle     EMBREE_GEOMETRY_TRIANGLE
        geometry-quad         EMBREE_GEOMETRY_QUAD
        geometry-curve        EMBREE_GEOMETRY_CURVE
        geometry-subdivision  EMBREE_GEOMETRY_SUBDIVISION
        geometry-user         EMBREE_GEOMETRY_USER
        geometry-instance     EMBREE_GEOMETRY_INSTANCE
        geometry-grid         EMBREE_GEOMETRY_GRID
        geometry-point        EMBREE_GEOMETRY_POINT
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
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
        -DEMBREE_TASKING_SYSTEM:STRING=${EMBREE_TASKING_SYSTEM}
        -DEMBREE_INSTALL_DEPENDENCIES=OFF
    MAYBE_UNUSED_VARIABLES
        EMBREE_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/embree-${VERSION} PACKAGE_NAME embree)
set(config_file "${CURRENT_PACKAGES_DIR}/share/embree/embree-config.cmake")
# Fix details in config.
file(READ "${config_file}" contents)
string(REPLACE "SET(EMBREE_BUILD_TYPE Release)" "" contents "${contents}")
string(REPLACE "/../../../" "/../../" contents "${contents}")
string(REPLACE "FIND_PACKAGE" "include(CMakeFindDependencyMacro)\n  find_dependency" contents "${contents}")
string(REPLACE "REQUIRED" "COMPONENTS" contents "${contents}")
string(REPLACE "/lib/cmake/embree-${VERSION}" "/share/embree" contents "${contents}")

if(NOT VCPKG_BUILD_TYPE)
    string(REPLACE "/lib/embree3.lib" "$<$<CONFIG:DEBUG>:/debug>/lib/embree3.lib" contents "${contents}")
endif()
file(WRITE "${config_file}" "${contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/uninstall.command" "${CURRENT_PACKAGES_DIR}/debug/uninstall.command")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
