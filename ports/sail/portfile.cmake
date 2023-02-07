vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HappySeaFox/sail
    REF v0.9.0-rc2
    SHA512 9cbf48b716ff13ff5d494166b6777c70f225c67842c00004706e00a8b411e5c59315c524865694c4698d661f7b675961df14ef0405b4a90d627107499587b544
    HEAD_REF master
)

# Enable selected codecs
set(ONLY_CODECS "")

foreach(CODEC avif bmp gif ico jpeg jpeg2000 pcx png qoi svg tga tiff wal webp xbm)
    if (${CODEC} IN_LIST FEATURES)
        list(APPEND ONLY_CODECS ${CODEC})
    endif()
endforeach()

list(JOIN ONLY_CODECS "\;" ONLY_CODECS_ESCAPED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"

    OPTIONS
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_ONLY_CODECS=${ONLY_CODECS_ESCAPED}
        -DSAIL_BUILD_APPS=OFF
        -DSAIL_BUILD_EXAMPLES=OFF
        -DSAIL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Move cmake configs
vcpkg_cmake_config_fixup(PACKAGE_NAME sail       CONFIG_PATH lib/cmake/sail       DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME sailcodecs CONFIG_PATH lib/cmake/sailcodecs DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME sailcommon CONFIG_PATH lib/cmake/sailcommon DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME sailc++    CONFIG_PATH lib/cmake/sailc++    DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME sailmanip  CONFIG_PATH lib/cmake/sailmanip  DO_NOT_DELETE_PARENT_CONFIG_PATH)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")


# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Unused because SAIL_COMBINE_CODECS is On
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sail/sail-common/config.h" "#define SAIL_CODECS_PATH \"${CURRENT_PACKAGES_DIR}/lib/sail/codecs\"" "")

# Handle usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
