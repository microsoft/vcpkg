if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/sjpeg
    REF 46da5aec5fce05faabf1facf0066e36e6b1c4dff
    SHA512 986e57c201a8ff00b01eb25e11b16736050f005cc8f6448ed6ad580234071ee1105408a7d2222715364ec40b3210c2054ae7a96dddf31657390cd3370154d444
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSJPEG_BUILD_EXAMPLES=OFF
        "-DSJPEG_ANDROID_NDK_PATH=$ENV{ANDROID_NDK_HOME}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/sjpeg/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
