vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Wohlstand/libADLMIDI
    REF 809f7e0021dbb7a0e5b2f67d54da2298f30a53c3
    SHA512 9b809ac96d1c1c9088073db3adc78ceb039974022a4937f32b7058bcba68fd3eaf5fb599176861f152cce9da7d079aa00dacdb3d61b66460d679c6d95a235a2f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hw-serial       USE_HW_SERIAL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_NUKED_OPL2_LLE_EMULATOR=ON
        -DUSE_NUKED_OPL3_LLE_EMULATOR=ON
        -DUSE_HW_SERIAL=ON
        -DWITH_HQ_RESAMPLER=OFF # requires zita-resampler
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libADLMIDI)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSE*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
