vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HappySeaFox/sail
    REF "v${VERSION}"
    SHA512 63ad4ee0cee6d5511e069f2203947c6ae0e9c0b64b3423d1f03f50f059b768d62fe658ae4631c1b7a3fdeb375f26f22ed5439ee30a480c5c3ccf2357a717ac6d
    HEAD_REF master
    PATCHES
        fix-always-nanosvg.diff
        fix-heif.patch
        fix-include-directory.patch
)

# Enable selected codecs
set(ONLY_CODECS "")

# List of codecs copy-pasted from SAIL
set(HIGHEST_PRIORITY_CODECS gif jpeg png svg webp)
set(HIGH_PRIORITY_CODECS    avif ico)
set(MEDIUM_PRIORITY_CODECS  heif openexr psd raw tiff video)
set(LOW_PRIORITY_CODECS     bmp hdr jpeg2000 jpegxl pnm qoi tga)
set(LOWEST_PRIORITY_CODECS  fli jbig pcx wal xbm xpm xwd)

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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test BUILD_TESTING
)

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
        ${FEATURE_OPTIONS}
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_ENABLE_OPENMP=${SAIL_ENABLE_OPENMP}
        -DSAIL_ONLY_CODECS=${ONLY_CODECS_ESCAPED}
        -DSAIL_BUILD_APPS=OFF
        -DSAIL_BUILD_EXAMPLES=OFF
        ${SAIL_WINDOWS_STATIC_CRT_FLAG}
)

vcpkg_cmake_install()

if (BUILD_TESTING AND NOT VCPKG_CROSSCOMPILING)
    vcpkg_cmake_build(
        TARGET test
        LOGFILE_BASE test
        ADD_BIN_TO_PATH
    )
endif()

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
