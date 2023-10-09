vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Wohlstand/libOPNMIDI
    REF "v${VERSION}"
    SHA512 735af8c65c54e1e57e9d3e8582465636c0efeb7a03c7b0f5e2ef16f5cfd14fb34e99f738bb5a5cb43fe44fc584c3241eee6ae21a0f604702f101442f42601bcd
    PATCHES 
        # patches from master, they should be removed when a new version is out
        cmake-package-export.patch
        cmake-build-shared-libs-support.patch
        disable-wopn2hpp.patch
        fix-build-without-sequencer.patch
        fix-pmdwin-emulator-include.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        midi-sequencer          WITH_MIDI_SEQUENCER
        mame-ym2612-emulator    USE_MAME_EMULATOR
        mame-ym2608-emulator    USE_MAME_2608_EMULATOR  
        nuked-emulator          USE_NUKED_EMULATOR
        gens-emulator           USE_GENS_EMULATOR
        gx-emulator             USE_GX_EMULATOR
        np2-emulator            USE_NP2_EMULATOR
        pmdwin-emulator         USE_PMDWIN_EMULATOR
        mus                     WITH_MUS_SUPPORT
        xmi                     WITH_XMI_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DUSE_VGM_FILE_DUMPER=OFF
        -DWITH_WOPN2HPP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libOPNMIDI)

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
