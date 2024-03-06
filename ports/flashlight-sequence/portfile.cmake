vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/sequence
    REF v${VERSION}
    SHA512 215bb4988fbdd31573965c3c5d88d40b247cbca49f092dcdb89b5f2ca422d5774e941de843433fd3effd8f09569a7e0c2cc61364b5f0a210f156933e4c00f16b
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp FL_SEQUENCE_USE_OPENMP
        cuda   FL_SEQUENCE_USE_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFL_SEQUENCE_BUILD_TESTS=OFF
        -DFL_SEQUENCE_BUILD_STANDALONE=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
    OPTIONS_RELEASE
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
