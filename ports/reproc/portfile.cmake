vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v14.2.3
    SHA512 acb3a0b90aca7bcfd1b0882b7094ba0f2f8dd8aa4a7c4a37d37780cebb23ef3c8842ca9a9aded337f607d832a95eed5cc7ccc120c64daef9a979a9d20aa07aad
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(TARGET reproc reproc++)
    vcpkg_fixup_cmake_targets(
        CONFIG_PATH share/${TARGET} 
        TARGET_PATH share/${TARGET}
    )
endforeach()

file(
    INSTALL ${SOURCE_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
