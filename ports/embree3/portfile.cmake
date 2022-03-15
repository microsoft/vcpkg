set(EMBREE3_VERSION 3.13.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v${EMBREE3_VERSION}
    SHA512 eef8d9101f0bf95d6706a495a9aa628c10749862aeb2baa6bba2f82fcc3a96467a28ca1f522d672eb5aa7b29824363674feda25832724da361b3334334a218cd
    HEAD_REF master
    PATCHES
        cmake_policy.patch
        fix-targets-file-not-found.patch
        installTBB.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} static EMBREE_STATIC_LIB)

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/embree)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
if(APPLE)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/uninstall.command" "${CURRENT_PACKAGES_DIR}/debug/uninstall.command")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)