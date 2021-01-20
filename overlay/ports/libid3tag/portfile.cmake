vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/mad/files/libid3tag/0.15.1b/libid3tag-0.15.1b.tar.gz"
    FILENAME "libid3tag-0.15.1b.tar.gz"
    SHA512 ade7ce2a43c3646b4c9fdc642095174b9d4938b078b205cd40906d525acd17e87ad76064054a961f391edcba6495441450af2f68be69f116549ca666b069e6d3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        10_utf16.diff
        11_unknown_encoding.diff
        CVE-2008-2109.patch
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/id3tagConfig.cmake.in" "${SOURCE_PATH}/id3tagConfig.cmake.in" COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Moves all .cmake files from /debug/share/libid3tag/ to /share/libid3tag/
# See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/libid3tag)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libid3tag RENAME copyright)
