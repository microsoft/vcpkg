vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davisking/dlib
    REF "v${VERSION}"
    SHA512 57ad366c80cf342e850dd8b73f17e2034b6cf699f1af37d038d7e41f4e298523489e67254be9e10b47e2c5e5769f69cd225d17837e3f0bf39a4fc1b53240fbf0
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/dlib/external")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "sqlite3"   DLIB_LINK_WITH_SQLITE3
        "fftw3"     DLIB_USE_FFTW
        "cuda"      DLIB_USE_CUDA
)

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(COMMON_OPTIONS -DUSE_SSE2_INSTRUCTIONS=OFF)
endif()

set(dbg_opts "")
if(VCPKG_TARGET_IS_WINDOWS)
  set(dbg_opts -DDLIB_ENABLE_ASSERTS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${COMMON_OPTIONS}
        -DDLIB_PNG_SUPPORT=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_PNG=ON
        -Dtest_for_libpng_worked=TRUE # try_compile ignores vcpkg setup
        -DDLIB_JPEG_SUPPORT=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_JPEG=ON
        -Dtest_for_libjpeg_worked=TRUE # try_compile ignores vcpkg setup
        -DDLIB_USE_BLAS=ON
        -DDLIB_USE_LAPACK=ON
        -DDLIB_GIF_SUPPORT=OFF
        -DDLIB_WEBP_SUPPORT=OFF
        -DDLIB_JXL_SUPPORT=OFF
        -DDLIB_USE_MKL_FFT=OFF
        -DDLIB_USE_FFMPEG=OFF
        -DDLIB_NO_GUI_SUPPORT=ON
    OPTIONS_DEBUG
        ${dbg_opts}
        #-DDLIB_ENABLE_STACK_TRACE=ON
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
  # Dlib encodes debug/release in its config.h. Patch it to respond to the NDEBUG macro instead. <- The below is using _DEBUG but there is no correct way to switch this on !windows
  # Only windows defines _DEBUG in debug builds.
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dlib/config.h" "/* #undef ENABLE_ASSERTS */" "#if defined(_DEBUG)\n#define ENABLE_ASSERTS\n#endif")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dlib/config.h" "#define DLIB_DISABLE_ASSERTS" "#if !defined(_DEBUG)\n#define DLIB_DISABLE_ASSERTS\n#endif")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dlib)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

# Remove other files not required in package
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/dlib/all"
    "${CURRENT_PACKAGES_DIR}/include/dlib/appveyor"
    "${CURRENT_PACKAGES_DIR}/include/dlib/test"
    "${CURRENT_PACKAGES_DIR}/include/dlib/travis"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_neon"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cudnn"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cuda"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cpp11"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_dlib_config"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_avx"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_sse4"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libjpeg"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libpng"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libjxl"
    "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libwebp"
    "${CURRENT_PACKAGES_DIR}/include/dlib/external/libpng/arm"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/dlib/LICENSE.txt")
