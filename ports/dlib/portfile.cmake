include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO davisking/dlib
    REF v19.7
    SHA512 a3877066e04a411d96e910f4229c60a86971a9290e840aa4a5b2f0b102e9b8c37bfede259b80b71ba066d21eb0aa2565808e51d0eab6397ff5fd2bac60dcedd5
    HEAD_REF master
)

file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/libjpeg)
file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/libpng)
file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/zlib)

# This fixes static builds; dlib doesn't pull in the needed transitive dependencies
file(READ "${SOURCE_PATH}/dlib/CMakeLists.txt" DLIB_CMAKE)
string(REPLACE "PNG_LIBRARY" "PNG_LIBRARIES" DLIB_CMAKE "${DLIB_CMAKE}")
file(WRITE "${SOURCE_PATH}/dlib/CMakeLists.txt" "${DLIB_CMAKE}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
        -DDLIB_LINK_WITH_SQLITE3=ON
        -DDLIB_USE_FFTW=ON
        -DDLIB_PNG_SUPPORT=ON
        -DDLIB_JPEG_SUPPORT=ON
        -DDLIB_USE_BLAS=OFF
        -DDLIB_USE_LAPACK=OFF
        -DDLIB_USE_CUDA=OFF
        -DDLIB_GIF_SUPPORT=OFF
        -DDLIB_USE_MKL_FFT=OFF
        #-DDLIB_USE_CUDA=ON
    OPTIONS_DEBUG
        -DDLIB_ENABLE_ASSERTS=ON
        #-DDLIB_ENABLE_STACK_TRACE=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/dlib)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Remove other files not required in package
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/all)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/test)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/travis) 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_neon)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cudnn)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cuda)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils/test_for_cpp11)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/external/libpng/arm)

# Dlib encodes debug/release in its config.h. Patch it to respond to the NDEBUG macro instead.
file(READ ${CURRENT_PACKAGES_DIR}/include/dlib/config.h _contents)
string(REPLACE "/* #undef ENABLE_ASSERTS */" "#if !defined(NDEBUG)\n#define ENABLE_ASSERTS\n#endif" _contents ${_contents})
string(REPLACE "#define DLIB_DISABLE_ASSERTS" "#if defined(NDEBUG)\n#define DLIB_DISABLE_ASSERTS\n#endif" _contents ${_contents})
file(WRITE ${CURRENT_PACKAGES_DIR}/include/dlib/config.h ${_contents})

file(READ ${CURRENT_PACKAGES_DIR}/share/dlib/dlib.cmake _contents)
string(REPLACE
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)"
    _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/dlib/dlib.cmake "${_contents}")

# Handle copyright
file(COPY ${SOURCE_PATH}/dlib/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/dlib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/dlib/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/dlib/COPYRIGHT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
