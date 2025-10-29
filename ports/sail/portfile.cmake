vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HappySeaFox/sail
    REF "v${VERSION}"
    SHA512 0e6bd4fb7910eda29e0cd6d96e31ff9a476d5836055e4653d6401ab72209eccd3624b8c1e92b7cd0d22ecdaa8ffde44b155da36da61c99ec0c06e1d388bd1d67
    HEAD_REF master
    PATCHES
        fix-heif.patch
        fix-include-directory.patch
)

# Enable selected codecs
set(ONLY_CODECS "")

# List of codecs copy-pased from SAIL
set(HIGHEST_PRIORITY_CODECS gif jpeg png svg webp)
set(HIGH_PRIORITY_CODECS    avif ico)
set(MEDIUM_PRIORITY_CODECS  heif openexr psd tiff)
set(LOW_PRIORITY_CODECS     bmp hdr jpeg2000 jpegxl pnm qoi tga)
set(LOWEST_PRIORITY_CODECS  jbig pcx wal xbm xpm xwd)

foreach(CODEC ${HIGHEST_PRIORITY_CODECS} ${HIGH_PRIORITY_CODECS} ${MEDIUM_PRIORITY_CODECS} ${LOW_PRIORITY_CODECS} ${LOWEST_PRIORITY_CODECS})
    if (CODEC IN_LIST FEATURES)
        list(APPEND ONLY_CODECS "${CODEC}")
    endif()
endforeach()

list(JOIN ONLY_CODECS "\;" ONLY_CODECS_ESCAPED)

# Enable OpenMP
if ("openmp" IN_LIST FEATURES)
    set(SAIL_ENABLE_OPENMP ON)
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

    if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(SAIL_WINDOWS_STATIC_CRT_FLAG "-DSAIL_WINDOWS_STATIC_CRT=OFF")
    else()
        set(SAIL_WINDOWS_STATIC_CRT_FLAG "-DSAIL_WINDOWS_STATIC_CRT=ON")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_ENABLE_OPENMP=${SAIL_ENABLE_OPENMP}
        -DSAIL_ONLY_CODECS=${ONLY_CODECS_ESCAPED}
        -DSAIL_BUILD_APPS=OFF
        -DSAIL_BUILD_EXAMPLES=OFF
        ${SAIL_WINDOWS_STATIC_CRT_FLAG}
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

# Unused because SAIL_COMBINE_CODECS is ON, removes an absolute path from the output
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sail-common/config.h" "#define SAIL_CODECS_PATH [^\r\n]+[\r\n]*" "" REGEX)

# Handle usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
