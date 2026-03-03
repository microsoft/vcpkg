if(EMSCRIPTEN)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ethindp/prism
  REF v0.7.1
  SHA512 7a412110cd0d5da23eafc78a979cfd7fdcfddef6d8ecc6a370afbf93914d41bf8b7a87cd8e0d44cd84b6b2c1d9de0621c0214892cef057c8f6c3c3424ecfb7b5
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
    -DPRISM_ENABLE_LINTING=OFF
    -DPRISM_ENABLE_VCPKG_SPECIFIC_OPTIONS=ON
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME prism CONFIG_PATH share/prism)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
