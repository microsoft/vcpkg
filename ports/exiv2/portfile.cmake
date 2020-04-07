include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF v0.27.2
    SHA512 349063fd8ef6c44b5b2f3f68aad839271a9cb8ff206af237d28d9e9d05dcdf43b61f3232d4566780b2898d62c20134e8ea65d588a19a664c0224750e4ea1340d
    HEAD_REF master
    PATCHES
        iconv.patch
        1059-Add-missing-library-link-on-Windows.patch # https://github.com/Exiv2/exiv2/pull/1059
)

if((NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") AND ("unicode" IN_LIST FEATURES))
    set(enable_win_unicode TRUE)
elseif()
    set(enable_win_unicode FALSE)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEXIV2_ENABLE_WIN_UNICODE:BOOL=${enable_win_unicode}
        -DEXIV2_BUILD_EXIV2_COMMAND:BOOL=FALSE
        -DEXIV2_BUILD_UNIT_TESTS:BOOL=FALSE
        -DEXIV2_BUILD_SAMPLES:BOOL=FALSE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/exiv2)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/exiv2
    @ONLY
)

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/exiv2 ${CURRENT_PACKAGES_DIR}/lib/exiv2)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/exiv2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/exiv2/COPYING ${CURRENT_PACKAGES_DIR}/share/exiv2/copyright)
