vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF 49a95d4566d47342b122303cf73585cf22653b0a
    SHA512 9197075ac4aaee46f46ff3bf3dbfc84972dc9ecf758d11b6abfd569934c572716ebe6e5bb302302afa78dc78a0b9c7f5ee3aea940f48e1246dcf2205439564fc
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
      -DPOLYHOOK_FEATURE_DETOURS=OFF # Requires asmtk, which depends on asmjit
      -DPOLYHOOK_FEATURE_INLINENTD=OFF # Disables as not compatible with latest asmjit: #https://github.com/stevemk14ebr/PolyHook_2_0/issues/221
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME PolyHook_2 CONFIG_PATH lib/PolyHook_2)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
