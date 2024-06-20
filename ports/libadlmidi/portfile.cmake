vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Wohlstand/libADLMIDI
    REF v${VERSION}
    SHA512 d827f13c60086b62bb4ffb098faeaa214fd83df52d3d5c19533b970d74b470c677e0aec76e91e05753574cf9bae1ccd02b77bd24d0ec1b2ad80b21cf541c7261
    PATCHES
        # patches from master, they should be removed when a new version is out
        cmake-package-export.patch
        cmake-build-shared-libs-support.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        midi-sequencer  WITH_MIDI_SEQUENCER
        embedded-banks  WITH_EMBEDDED_BANKS
        mus             WITH_MUS_SUPPORT
        xmi             WITH_XMI_SUPPORT
        dosbox-emulator USE_DOSBOX_EMULATOR
        nuked-emulator  USE_NUKED_EMULATOR
        opal-emulator   USE_OPAL_EMULATOR
        java-emulator   USE_JAVA_EMULATOR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        ${FEATURE_OPTIONS}
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
