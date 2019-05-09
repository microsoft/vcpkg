include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF 0.27
    SHA512 ec605db73abcf3cc2df78c1fc3aae5335a51192f660668e39a4f20fc7f372b18c3cec9b704e1c71c356315fd75e791622de1dffe576432ee0fb12bf63a98a423
    HEAD_REF master
    PATCHES
        iconv.patch
)

if(WIN32 AND ("unicode" IN_LIST FEATURES))
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
#        -DEXIV2_ENABLE_NLS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/exiv2/cmake")

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/exiv2
    @ONLY
)

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright 
file(COPY ${SOURCE_PATH}/ABOUT-NLS DESTINATION ${CURRENT_PACKAGES_DIR}/share/exiv2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/exiv2/ABOUT-NLS ${CURRENT_PACKAGES_DIR}/share/exiv2/copyright)
