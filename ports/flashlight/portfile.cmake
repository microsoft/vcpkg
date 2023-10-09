vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/flashlight
    REF 6653536c24f31ba515d425ad834faddef4a64adb
    SHA512 a7cae64c1e5fe225798767dfdaef776a54f6e02a6fcfc45254c83bdb17d6d03c0b030026a28ed14f6fb421edaeb80bc19f7c6947aedaa799f337b64dd4910221
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
