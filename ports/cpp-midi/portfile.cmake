vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-midi
    REF "${VERSION}"
    SHA512 10d1adf6adb4114e4d39c1380c59a772ed34eb8b171c4070313f7eaa3a5d8460bfb08e344756d2b4a520a4cb0e92111fda12fa8754ea0192898da25da178a87d
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CPP_MIDI_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP_MIDI_BUILD_STATIC=${CPP_MIDI_BUILD_STATIC}
        -DCPP_MIDI_BUILD_TESTS=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
