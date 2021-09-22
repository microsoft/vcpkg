vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jerryscript-project/jerryscript
    REF 3bcd48f72d4af01d1304b754ef19fe1a02c96049
    SHA512 98cafd99baeac6fd136c17be6786dcd152e95a7b717c60672f04f0ca240b14099317ebfdfaf0ab374a74f32e9be20a688ff3ff9d65103e1244a6af074dacdd66 
    HEAD_REF master
    #PATCHES
    #    python-as-param.patch # from upstream to set python
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool JERRY_CMDLINE
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DPYTHON="${PYTHON3}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
