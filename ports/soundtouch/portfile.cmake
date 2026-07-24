vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    GITHUB_HOST https://codeberg.org
    REPO soundtouch/soundtouch
    REF ${VERSION}
    SHA512 97e4afcce100f210d89c665dd83f4eaa7b0bec88ba35ba1cf29729e9260d143a5c0f89156646c4dddc83030c5f6b8493c6abc1a82bfba52ed6a87929c8e0fdea
    HEAD_REF master
    PATCHES
        fix-install-includes.patch
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
