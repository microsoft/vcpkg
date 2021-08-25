vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jerryscript-project/jerryscript
    REF d00f4810b0e8eaa6a6755e2d0ecbd1713ecfca49
    SHA512 9e0c6c464a7e33f060d7a71df2555cbf865e5e86944f104801664531e3a9cf6f1109ecf78c9b3becb9e36f71b458a8085bfbe5b98ef52b513a0345940a1d38bb 
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
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DPYTHON="${PYTHON3}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
