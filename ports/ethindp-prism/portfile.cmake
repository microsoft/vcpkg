if(EMSCRIPTEN)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ethindp/prism
  REF v0.18.4
  SHA512 50346fe97d69f0086774b3ca18a0aef06cbbe40f7ea11f9dddbf7dc1c1de78735c34add684be921722c1456020ffff20500d4ec5a02dc16b96e165b0d2c13b5c
  HEAD_REF master
  PATCHES
    xbox-games-partition.patch
)
vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    speech-dispatcher PRISM_ENABLE_SPEECH_DISPATCHER_BACKEND
    gdk-speech PRISM_ENABLE_GDK_SPEECH_BACKEND
)
if(VCPKG_TARGET_IS_XBOX)
  # GDK speech is the only speech backend on Xbox, so it is always required there.
  list(APPEND FEATURE_OPTIONS -DPRISM_ENABLE_GDK_SPEECH_BACKEND=ON)
endif()
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPRISM_ENABLE_TESTS=OFF
    -DPRISM_ENABLE_DEMOS=OFF
    -DPRISM_ENABLE_LINTING=OFF
    -DPRISM_ENABLE_GDEXTENSION=OFF
    -DPRISM_ENABLE_LEGACY_BACKENDS=ON
    -DPRISM_ENABLE_POWER_MANAGEMENT=ON
    -DPRISM_ENABLE_SPIEL_BACKEND=OFF
    ${FEATURE_OPTIONS}
    -DPRISM_DEPENDENCY_PROVIDER=SYSTEM
)
vcpkg_cmake_install()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
  vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/prism.h"
    "#if defined(_WIN32)\n#if defined(PRISM_STATIC)"
    "#if defined(_WIN32)\n#ifndef PRISM_STATIC\n#define PRISM_STATIC\n#endif\n#if defined(PRISM_STATIC)"
  )
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME prism CONFIG_PATH share/prism)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST
  "${SOURCE_PATH}/LICENSE"
  "${SOURCE_PATH}/LICENSES/djinni/LICENSE"
  "${SOURCE_PATH}/LICENSES/dr_wav/LICENSE"
  "${SOURCE_PATH}/LICENSES/moderncom/LICENSE"
  "${SOURCE_PATH}/LICENSES/wayland-protocols/LICENSE"
)
