vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Viskores/viskores
    REF "v${VERSION}"
    SHA512 4ec30e96e8f61161255145aad44e986fe34d4ffc3268600d4e54ab4d0a583eaf3ef499d26ae00442b1204c4b202c741b1720438d00f3dc42d05119020a86571c
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/viskores/thirdparty/diy/viskoresdiy/include/viskoresdiy/thirdparty/fmt")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        anari   Viskores_ENABLE_ANARI
        hdf5    Viskores_ENABLE_HDF5_IO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DViskores_INSTALL_CONFIG_DIR=share/${PORT}
        -DViskores_INSTALL_SHARE_DIR=share/${PORT}
-DVCPKG_TRACE_FIND_PACKAGE=1
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
