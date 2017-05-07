# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dlib-19.4)
vcpkg_download_distfile(ARCHIVE
	URLS "http://dlib.net/files/dlib-19.4.tar.bz2"
	FILENAME "dlib-19.4.tar.bz2"
	SHA512 c5ae22c507b57a13d880d79e9671730829114d0276508b0a41b373d3abae9057d960fce84fafe1be468d943910853baaa70c88f2516e20a0c41f3895bf217f7b
)
vcpkg_extract_source_archive(${ARCHIVE})
file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/libjpeg)
file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/libpng)
file(REMOVE_RECURSE ${SOURCE_PATH}/dlib/external/zlib)

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

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Remove other files not required in package
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/all)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/test)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/travis) 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/cmake_utils)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/dlib/external/libpng/arm)

# Handle copyright
file(COPY ${CURRENT_PACKAGES_DIR}/share/doc/dlib/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/dlib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/dlib/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/dlib/COPYRIGHT)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
