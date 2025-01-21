# yarpl only support static build in Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO rsocket/rsocket-cpp
  REF 45ed594ebd6701f40795c31ec922d784ec7fc921
  SHA512 51871253524b93a9622fa0f562019605b6034e4089cd955810050b4d43ff020813d632ea1e91bcaca0a8659638908c51df6eb686ba4f6583d4c15c04d5dc35bd
  HEAD_REF master
  PATCHES
    fix-cmake-config.patch
    fix-find-dependencies.patch
    use-cpp-17.patch
    fix-folly.patch
    fix-rsockserver-build-error.patch
    fix-yarpl.patch
    fix-c2665.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME yarpl CONFIG_PATH lib/cmake/yarpl DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rsocket)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/include/yarpl/perf"
  "${CURRENT_PACKAGES_DIR}/include/yarpl/cmake"
  "${CURRENT_PACKAGES_DIR}/include/yarpl/test"
  "${CURRENT_PACKAGES_DIR}/include/rsocket/examples"
  "${CURRENT_PACKAGES_DIR}/include/rsocket/test"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
