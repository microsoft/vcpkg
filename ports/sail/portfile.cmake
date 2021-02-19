vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF a7b8cdb
    SHA512 402b0e05ce99b5abeebf695a132121cc59789834d5a296ffada34fa3090c16ffc2266e98393e10136e31480b2378b966a8a48a153240f43b0196d986316aa9df
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SAIL_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAIL_STATIC=${SAIL_STATIC}
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_BUILD_EXAMPLES=OFF
        -DSAIL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sail)

# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Handle usage
if (UNIX AND NOT APPLE)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage.unix DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage.unix ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage)
else()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
