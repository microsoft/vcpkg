vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF e753f16
    SHA512 b80076f836ee20bbdaae23c8bc09694186ff7a9939a7b8e7944becd17d7862d0655bd515ba437577c610ca5113941e5411a8cc5d9b591633cfb65443071ea88d
    HEAD_REF feature/static
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SAIL_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAIL_VCPKG_PORT=ON
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

# Handle cmake wrapper
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle usage
if (UNIX AND NOT APPLE)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage.unix DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage.unix ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage)
else()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
