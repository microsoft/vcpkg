vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jerryscript-project/jerryscript
    REF v2.4.0
    SHA512 e96e6c6a2207ff869474801a1f8bbd3ce453d4076e558736ebf6962ccab08540f57cf932ec43bcd40429e21f1c6453d77874dd0a467d91a15d8357257533c1ea 
    HEAD_REF master
    PATCHES
        python-as-param.patch # from upstream to set python
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
