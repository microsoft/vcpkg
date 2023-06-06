vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/text
    REF v0.0.3
    SHA512 8bf5a60ee064f8276ee1a90f2f74bdb17cad7c75b33196940d4455ac4fd6d14f44690ec42eab4a122f3d8ad8934a42d8ccaf758d85d3c39784cda95bc5ef6351
    HEAD_REF main
)

# Default flags
set(FL_DEFAULT_VCPKG_CMAKE_FLAGS
  -DFL_TEXT_BUILD_TESTS=OFF
  -DFL_TEXT_BUILD_STANDALONE=OFF
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON # flashlight-text doesn't explicitly export symbols
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    kenlm FL_TEXT_USE_KENLM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FL_DEFAULT_VCPKG_CMAKE_FLAGS}
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
