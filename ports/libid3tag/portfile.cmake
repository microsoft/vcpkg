vcpkg_fail_port_install(ON_TARGET "uwp")
if((VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64") AND VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} does not support Windows ARM")
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mad/libid3tag
    REF 0.15.1b
    FILENAME libid3tag-0.15.1b.tar.gz
    SHA512 ade7ce2a43c3646b4c9fdc642095174b9d4938b078b205cd40906d525acd17e87ad76064054a961f391edcba6495441450af2f68be69f116549ca666b069e6d3
    PATCHES
        10_utf16.diff
        11_unknown_encoding.diff
        CVE-2008-2109.patch
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/id3tagConfig.cmake.in" "${SOURCE_PATH}/id3tagConfig.cmake.in" COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/id3tag TARGET_PATH share/id3tag)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
