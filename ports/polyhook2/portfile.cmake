vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  0fcced133f5b618883a2c2316c872f3e4a214cf2
    SHA512 9e2a3b62daf48dcbdaa75d20f886faa64d95c893610af36bce68a8c887a246af246bb52fd0e385fd3cc3c37ddadc6a7cea2495d46c3b0a1b0e75891ba532cddc
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
