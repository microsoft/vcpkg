vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF 8cd6cb4ef0f2a599f35bdd46ac5833843aea6523
    SHA512 93e6fcbb47f4b894c325766e1b2c146cebfe73424473ce0f52c8c923bd5b1276aebb3af03da9fc7027e2027994663c47a5a4f5a4f3c4a997a322886ac43401ec
    HEAD_REF master
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
