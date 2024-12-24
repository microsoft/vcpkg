vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    GITHUB_HOST https://codeberg.org
    REPO soundtouch/soundtouch
    REF ${VERSION}
    SHA512 9cc507e15be065fe404e3f9ac71cdc596474c4a86b04a4b969c6c3ed4aff865cdf6aee24929046818a7d3791f005778aea112d74ef4d8f60b05460755a08dbe3
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    soundstretch SOUNDSTRETCH
    soundtouchdll SOUNDTOUCH_DLL
)

if(SOUNDTOUCH_DLL)
  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SoundTouch)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(SOUNDSTRETCH)
  vcpkg_copy_tools(TOOL_NAMES soundstretch AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.TXT")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
