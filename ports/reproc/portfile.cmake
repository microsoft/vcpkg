vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v10.0.3
    SHA512 6d102962fbfb61b239d243fd38f7519c28cf7098e2e1a2bfd19035fa7152f4dcc51875683c76c1fa7274b786dde4b90873ae4a1eb6e5d9e485e6614ab06bf0d2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROCXX=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(TARGET reproc reprocxx)
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
