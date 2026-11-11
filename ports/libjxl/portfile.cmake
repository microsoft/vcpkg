vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjxl/libjxl
    REF "v${VERSION}"
    SHA512 f5a6cc4c875c9cdd217001096d34e5912afffdf3a58bae816c1c28c7e241eb0909ea37af0bef6d4b2fb8fae20ae94e29b2ef30fb65f778d4a7d62e07e20e3f85
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        fix-jxl-static.diff
        fix-pkgconfig.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools JPEGXL_ENABLE_TOOLS
        tools VCPKG_LOCK_FIND_PACKAGE_GIF
        tools VCPKG_LOCK_FIND_PACKAGE_JPEG
        tools VCPKG_LOCK_FIND_PACKAGE_PNG
)

if(VCPKG_TARGET_IS_UWP)
    string(APPEND VCPKG_C_FLAGS " /wd4146")
    string(APPEND VCPKG_CXX_FLAGS " /wd4146")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DJPEGXL_VERSION=${JPEGXL_VERSION}"
        -DJPEGXL_FORCE_SYSTEM_HWY=ON
        -DJPEGXL_FORCE_SYSTEM_BROTLI=ON
        -DJPEGXL_FORCE_SYSTEM_LCMS2=ON
        ${FEATURE_OPTIONS}
        -DJPEGXL_ENABLE_BENCHMARK=OFF
        -DJPEGXL_ENABLE_DOXYGEN=OFF
        -DJPEGXL_ENABLE_EXAMPLES=OFF
        -DJPEGXL_ENABLE_FUZZERS=OFF
        -DJPEGXL_ENABLE_JNI=OFF
        -DJPEGXL_ENABLE_MANPAGES=OFF
        -DJPEGXL_ENABLE_OPENEXR=OFF
        -DJPEGXL_ENABLE_PLUGINS=OFF
        -DJPEGXL_ENABLE_SJPEG=OFF
        -DJPEGXL_ENABLE_SKCMS=OFF
        -DJPEGXL_ENABLE_TCMALLOC=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DJPEGXL_BUNDLE_LIBPNG=OFF
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_GIF
        VCPKG_LOCK_FIND_PACKAGE_JPEG
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(JPEGXL_ENABLE_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES cjxl djxl jxlinfo jxltran AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/jxl/jxl_export.h" "ifdef JXL_STATIC_DEFINE" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/jxl/jxl_cms_export.h" "ifdef JXL_CMS_STATIC_DEFINE" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/jxl/jxl_threads_export.h" "ifdef JXL_THREADS_STATIC_DEFINE" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
