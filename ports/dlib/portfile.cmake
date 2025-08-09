vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davisking/dlib
    REF "v${VERSION}"
    SHA512 a4bcb2d013bd2b0000530d684c9c4b9f047f9fa6216174b3cb26d96f66c4a302d0bd1733d0ba35626d57133d9159f90114ab51a3af8fb9c493ff3e74dcc73911
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        find_blas.patch
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
        -DDLIB_JPEG_SUPPORT=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_JPEG=ON
        -DDLIB_USE_BLAS=ON
        -DDLIB_USE_LAPACK=ON
        -DDLIB_GIF_SUPPORT=OFF
        -DDLIB_WEBP_SUPPORT=OFF
        -DDLIB_USE_MKL_FFT=OFF
        -DDLIB_USE_FFMPEG=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_X11=ON
    OPTIONS_DEBUG
        ${dbg_opts}
        #-DDLIB_ENABLE_STACK_TRACE=ON
    MAYBE_UNUSED_OPTIONS
        CMAKE_DISABLE_FIND_PACKAGE_X11 # Not checked on Windows
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

# Remove other files not required in package
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/all")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/appveyor")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/test")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/travis")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_neon")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cudnn")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cuda")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cpp11")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_avx")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_sse4")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libjpeg")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libpng")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libjxl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_libwebp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/dlib/external/libpng/arm")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/dlib/LICENSE.txt")
