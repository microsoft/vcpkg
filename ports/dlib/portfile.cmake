vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davisking/dlib
    REF "v${VERSION}"
    SHA512 5104f12395a48ad2a9c196faab1b92d8ed5aaa026fff67f9a915ffd9a3c132ee2f68ce8b50a3c0bd3138ac4b42435bf6c0c5aa641bfabac47cde39ca465fe2f4
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        find_blas.patch
        fix-lapack.patch
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

# Workaround: The fix-dependencies and fix-lapack patches insert find_dependency
# calls for BLAS/LAPACK AFTER the include of the targets file (dlib.cmake) in
# dlibConfig.cmake. CMake fails because LAPACK::LAPACK and BLAS::BLAS are
# referenced in dlib.cmake before they are defined.
# Fix: remove the misplaced calls and inject explicit find_package calls (which
# go through the vcpkg cmake wrappers) before the targets include block.
set(_dlib_config_file "${CURRENT_PACKAGES_DIR}/share/${PORT}/dlibConfig.cmake")
file(READ "${_dlib_config_file}" _dlib_config_contents)
# Remove original misplaced find_dependency calls
string(REPLACE "find_dependency(BLAS)
find_dependency(LAPACK)" "# BLAS/LAPACK: moved before targets include" _dlib_config_contents "${_dlib_config_contents}")
# Insert find_package calls before the targets file include
string(REPLACE "# Our library dependencies (contains definitions for IMPORTED targets)" [[
find_package(BLAS)
if(NOT TARGET BLAS::BLAS AND BLAS_FOUND AND BLAS_LIBRARIES)
    add_library(BLAS::BLAS INTERFACE IMPORTED)
    set_target_properties(BLAS::BLAS PROPERTIES INTERFACE_LINK_LIBRARIES "${BLAS_LIBRARIES}")
endif()
find_package(LAPACK)
if(NOT TARGET LAPACK::LAPACK AND LAPACK_FOUND AND LAPACK_LIBRARIES)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)
    set_target_properties(LAPACK::LAPACK PROPERTIES INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}")
endif()

# Our library dependencies (contains definitions for IMPORTED targets)]] _dlib_config_contents "${_dlib_config_contents}")
file(WRITE "${_dlib_config_file}" "${_dlib_config_contents}")

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
