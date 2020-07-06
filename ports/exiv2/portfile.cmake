vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF 194bb65ac568a5435874c9d9d73b1c8a68e4edec #v0.27.3
    SHA512 35a5a41e0a6cfe04d1ed005c8116ad4430516402b925db3d4f719e2385e2cfb09359eb7ab51853bc560138f221900778cd2e2d39f108c513b3e7d22dbb9bf503
    HEAD_REF master
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
