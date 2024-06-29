vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF fd2a88f09c8ae89440858fc52573656141013c7f
    SHA512 09eef1b0ca75f9420fa258c4290b6b62a3115531e77c91f9d223b2c4a10e8ee95b243bf9f6598d7c55b76ca4e4a185cdf1231b40d5ef87d7d405b8b434eb6cb0
    HEAD_REF master
    PATCHES fix-dep.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        exception POLYHOOK_FEATURE_EXCEPTION
        detours   POLYHOOK_FEATURE_DETOURS
        inlinentd POLYHOOK_FEATURE_INLINENTD
        pe        POLYHOOK_FEATURE_PE
        virtuals  POLYHOOK_FEATURE_VIRTUALS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(BUILD_STATIC_RUNTIME ON)
else()
    set(BUILD_STATIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
      -DPOLYHOOK_BUILD_SHARED_LIB=${BUILD_SHARED_LIB}
      -DPOLYHOOK_BUILD_STATIC_RUNTIME=${BUILD_STATIC_RUNTIME}
      -DPOLYHOOK_USE_EXTERNAL_ASMJIT=ON
      -DPOLYHOOK_USE_EXTERNAL_ASMTK=ON
      -DPOLYHOOK_USE_EXTERNAL_ZYDIS=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME PolyHook_2 CONFIG_PATH lib/PolyHook_2)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
