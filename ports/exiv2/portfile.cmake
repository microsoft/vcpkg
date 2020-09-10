#https://github.com/Exiv2/exiv2/issues/1063
vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF 194bb65ac568a5435874c9d9d73b1c8a68e4edec #v0.27.3
    SHA512 35a5a41e0a6cfe04d1ed005c8116ad4430516402b925db3d4f719e2385e2cfb09359eb7ab51853bc560138f221900778cd2e2d39f108c513b3e7d22dbb9bf503
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    unicode EXIV2_ENABLE_WIN_UNICODE
    xmp     EXIV2_ENABLE_XMP
    video   EXIV2_ENABLE_VIDEO
)

if("unicode" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature unicode only supports Windows platform.")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXIV2_BUILD_EXIV2_COMMAND:BOOL=FALSE
        -DEXIV2_BUILD_UNIT_TESTS:BOOL=FALSE
        -DEXIV2_BUILD_SAMPLES:BOOL=FALSE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/exiv2)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}
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
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)