if(NOT EMSCRIPTEN)
  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
else()
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ethindp/prism
  REF v0.4.7
  SHA512 c357aa61d81d4bd39464bc30abc89a402f39d18d2c26c51c61e8da83e5b9596d21a0dcff3d85ef2c404b5b883fe0befc710a649990878fa7630e20d0a919a66b
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
