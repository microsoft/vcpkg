
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO midi2-dev/AM_MIDI2.0Lib
    REF "v${VERSION}"
    SHA512 020aa895fbdb3824f86d377835209aacba59bf8f6de59144d6b6d4c90dafafb659a1b0b8f7df1fdb4a6ddd4ba5ce236618b8b5a390029efe829b5b3f6cf33d25
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

