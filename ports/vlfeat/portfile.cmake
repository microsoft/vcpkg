vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vlfeat/vlfeat
    REF 1b9075fc42fe54b42f0e937f8b9a230d8e2c7701
    SHA512 6d317a1a9496ccac80244553d555fe060b150ccc7ee397a353b64f3a8451f24d1f03d8c00ed04cd9fc2dc066a5c5089b03695c614cb43ffa09be363660278255
    PATCHES
        expose_missing_symbols.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
