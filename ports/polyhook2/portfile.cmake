vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  bb49bc5543ebef7402a222f4022d7cc66cce7584
    SHA512 dc02a1d13c0a6607962ece01e8108c197494ac2c93c29bab0b906d20b7776c977afade9fb03d008a13dd2752e3d9a193b2aa8f43d3b0e6efce9cb8ae60533358
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    capstone  POLYHOOK_DISASM_CAPSTONE
    zydis     POLYHOOK_DISASM_ZYDIS
    exception POLYHOOK_FEATURE_EXCEPTION
    detours   POLYHOOK_FEATURE_DETOURS
    inlinentd POLYHOOK_FEATURE_INLINENTD
    pe        POLYHOOK_FEATURE_PE
    virtuals  POLYHOOK_FEATURE_VIRTUALS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_SHARED_LIB OFF)
else()
    set(BUILD_SHARED_LIB ON)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(BUILD_STATIC_RUNTIME ON)
else()
    set(BUILD_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA  
    OPTIONS ${FEATURE_OPTIONS}
      -DPOLYHOOK_BUILD_SHARED_LIB=${BUILD_SHARED_LIB}
      -DPOLYHOOK_BUILD_STATIC_RUNTIME=${BUILD_STATIC_RUNTIME}
      -DPOLYHOOK_USE_EXTERNAL_ASMJIT=ON
      -DPOLYHOOK_USE_EXTERNAL_CAPSTONE=ON
      -DPOLYHOOK_USE_EXTERNAL_ZYDIS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/PolyHook_2 TARGET_PATH share/PolyHook_2)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
