vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/flashlight
    REF 6653536c24f31ba515d425ad834faddef4a64adb
    SHA512 0
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    afcuda   FL_USE_ARRAYFIRE
    afcuda   FL_ARRAYFIRE_USE_CUDA
    cudnn    FL_USE_CUDNN
    onednn   FL_USE_ONEDNN
    nccl     FL_USE_NCCL
    gloo     FL_USE_GLOO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DFL_BUILD_TESTS=OFF
        -DFL_BUILD_EXAMPLES=OFF
        -DFL_BUILD_STANDALONE=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        FL_ARRAYFIRE_USE_CUDA
        FL_ARRAYFIRE_USE_CPU
    OPTIONS_DEBUG
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share/flashlight"
    OPTIONS_RELEASE
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/flashlight"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
