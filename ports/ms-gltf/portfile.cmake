
vcpkg_fail_port_install(MESSAGE "ms-gltf currently only supports Windows and Mac platforms" ON_TARGET "uwp" "linux" "ios")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO    microsoft/glTF-SDK
    REF     r1.9.5.0
    SHA512  1a067717cc75a7e040bbb814d26ad1ab15d24cd56b1adc4e8603ea7495b549715afe3d45d9d25efd9003f62d0b19b7ece1cf9c9e7b8c0b3af75a5223365133d1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_UNIT_TESTS=false
        -DENABLE_SAMPLES=false
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gltf RENAME copyright
)
