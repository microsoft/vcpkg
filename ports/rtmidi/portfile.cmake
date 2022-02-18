# Upstream uses CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which causes issues
# https://github.com/thestk/rtmidi/blob/4.0.0/CMakeLists.txt#L20
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtmidi
    REF dda792c5394375769466ab1c1d7773e741bbd950 # 4.0.0
    SHA512 cb1ded29c0b22cf7f38719131a9572a4daba7071fd8cf8b5b8d7306560a218bb0ef42150bf341b76f4ddee0ae087da975116c3b153e7bb908f2a674ecacb9d7a
    HEAD_REF master
    PATCHES
        fix-POSIXname.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRTMIDI_API_ALSA=OFF
        -DRTMIDI_API_JACK=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
