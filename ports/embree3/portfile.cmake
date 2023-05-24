
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v${VERSION}
    SHA512 13ae19b1750197fb4887ba601c75d1b54b3c388224672b6561dd922bc9b9747139cf46ce554727e3afa13dcf152ce4d703935cb9105ced792b011f2d05fa3e95
    HEAD_REF master
    PATCHES
        no-runtime-install.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static EMBREE_STATIC_LIB)
string(COMPARE EQUAL ${VCPKG_CRT_LINKAGE} static EMBREE_STATIC_RUNTIME)

if (NOT VCPKG_TARGET_IS_OSX)
    if ("avx512" IN_LIST FEATURES)
        message(FATAL_ERROR "Microsoft Visual C++ Compiler does not support feature avx512 officially.")
    endif()

    vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            avx     EMBREE_ISA_AVX
            avx2    EMBREE_ISA_AVX2
            avx512  EMBREE_ISA_AVX512
            sse2    EMBREE_ISA_SSE2
            sse42   EMBREE_ISA_SSE42
    )
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(LENGTH FEATURES FEATURE_COUNT)
    if (FEATURE_COUNT GREATER 2)
        message(WARNING [[
Using Embree as static library is not supported with AppleClang >= 9.0 when multiple ISAs are selected.
Please install embree3 with only one feature using command "./vcpkg install embree3[core,FEATURE_NAME]"
Only set feature avx automaticlly.
    ]])
        set(FEATURE_OPTIONS
            -DEMBREE_ISA_AVX=ON
            -DEMBREE_ISA_AVX2=OFF
            -DEMBREE_ISA_AVX512=OFF
            -DEMBREE_ISA_SSE2=OFF
            -DEMBREE_ISA_SSE42=OFF
        )
    endif()
endif()

vcpkg_replace_string("${SOURCE_PATH}/common/cmake/installTBB.cmake" "IF (EMBREE_STATIC_LIB)" "IF (0)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
        -DEMBREE_INSTALL_DEPENDENCIES=OFF
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
if(APPLE)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/uninstall.command" "${CURRENT_PACKAGES_DIR}/debug/uninstall.command")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
