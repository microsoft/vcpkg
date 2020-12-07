vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF 96924c94dabe362bbb1588aa70209e638e6fb35c
    SHA512 bc3e9ecf39d54321314d09209f356a2491893591a016b1619abcdea8c1fb1fa8ba1f9858f4e758641df083ed237a2ec9f0af13e0f1d802502257644168ae8907
    HEAD_REF master
    PATCHES
        fix_targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/kubazip)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/UNLICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
