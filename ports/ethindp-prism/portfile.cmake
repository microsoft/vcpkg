if(NOT EMSCRIPTEN)
  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
else()
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  ethindp/prism
  REF
  v0.4.6
  SHA512
  a243a53bf49cc029ec50aab78ad7df2a66fd99603349366e9aae113bd49eb0e9a2ff47ef932b9df724d294aff1a4c5f1770e7e8421f22bfafe35537506a23f45
  HEAD_REF
  master)
vcpkg_check_features(
  OUT_FEATURE_OPTIONS
  FEATURE_OPTIONS
  FEATURES
  orca
  PRISM_VCPKG_WANTS_ORCA_BACKEND
  speech-dispatcher
  PRISM_VCPKG_WANTS_SPEECH_DISPATCHER_BACKEND)
vcpkg_cmake_configure(
  SOURCE_PATH
  "${SOURCE_PATH}"
  OPTIONS
  -DPRISM_ENABLE_TESTS=OFF
  -DPRISM_ENABLE_DEMOS=OFF
  -DPRISM_ENABLE_CLANG_TIDY=OFF
  -DPRISM_ENABLE_VCPKG_SPECIFIC_OPTIONS=ON
  ${FEATURE_OPTIONS})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME prism CONFIG_PATH share/prism)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
