if(NOT EMSCRIPTEN)
  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
else()
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ethindp/prism
  REF v0.5.0
  SHA512 a0c6b774ab4e87c2c2f2c556d78a40a45eaf52d7ddaab4cb7dbc50947e6919958977abdbfc37185263dbe6d3f3cce3a651d7927202596713e2de75c4a42d92a4
  HEAD_REF master
)
vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    orca PRISM_VCPKG_WANTS_ORCA_BACKEND
    speech-dispatcher PRISM_VCPKG_WANTS_SPEECH_DISPATCHER_BACKEND
)
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPRISM_ENABLE_TESTS=OFF
    -DPRISM_ENABLE_DEMOS=OFF
    -DPRISM_ENABLE_CLANG_TIDY=OFF
    -DPRISM_ENABLE_VCPKG_SPECIFIC_OPTIONS=ON
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME prism CONFIG_PATH share/prism)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
