vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF 8a46b552d28b15ef584f9a6153c2c866754f7b94 # v12.0.0
    SHA512 df5b9b2024a2f8e0ed3ac3d0f8df4b251601a91c037b0a81825fd7a0b034ed2e3fbd1d107fa307b00b828b15ac74fccd85df58686a7ab74de82640a889c680b2
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
