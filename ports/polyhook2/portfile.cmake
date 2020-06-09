vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  879ec97a63d9a82b20a9243d6fa9afddbdb47786
    SHA512 ca479531cc98ac055452d4333a9e69c21de797c5f7d1ae9c52cc2f0fe0b4a0085f201d056f97d9d4682efae4c5f8c46b7dc42649f150fe3855d04f45a4d8afcd
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
