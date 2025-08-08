vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/wolf-midi
    REF "${VERSION}"
    SHA512 6359707d2631bd2e6e3f2e34b6ca1da3718a312c09968323b1598e83085beae8417d0c8d465ce50550af6843c9c5f060f799ef6d5a78a013a08cfbaa84506cff
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" WOLF_MIDI_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWOLF_MIDI_BUILD_STATIC=${WOLF_MIDI_BUILD_STATIC}
        -DWOLF_MIDI_BUILD_TESTS=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
