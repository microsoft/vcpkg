
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO midi2-dev/AM_MIDI2.0Lib
    REF "v${VERSION}"
    SHA512 6cf5979de8735b172e05da868b478dae8d225d8fb7909e4b53fbda5c18d998383bca9fe913aa7848ed4ff7ac24a49cf74e857397a43948cff4a75bb9687338af
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

