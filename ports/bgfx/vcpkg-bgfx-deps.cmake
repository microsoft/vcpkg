# Passed to bgfx.cmake as BGFX_CMAKE_USER_SCRIPT: it runs before bgfx.cmake loads its
# 3rdparty/*.cmake files and is also included by the installed bgfxConfig.cmake.
if(NOT DEFINED BGFX_CMAKE_USER_SCRIPT)
	# Consumer side: dependencies of the exported bimg targets
	include(CMakeFindDependencyMacro)
	find_dependency(lodepng CONFIG)
	find_dependency(miniz CONFIG)
	find_dependency(tinyexr CONFIG)
	find_dependency(unofficial-libsquish CONFIG)
	return()
endif()

# Build side: setting <NAME>_LIBRARIES makes the matching 3rdparty/*.cmake skip the vendored copy
find_package(lodepng CONFIG REQUIRED)
find_package(miniz CONFIG REQUIRED)
find_package(tinyexr CONFIG REQUIRED)
find_package(unofficial-libsquish CONFIG REQUIRED)
find_package(Stb REQUIRED)

set(LOADPNG_LIBRARIES lodepng)
set(MINIZ_LIBRARIES miniz::miniz)
set(TINYEXR_LIBRARIES unofficial::tinyexr::tinyexr)
set(LIBSQUISH_LIBRARIES unofficial::libsquish::squish)

# bimg_decode only reaches bimg/3rdparty (simplewebp, ...) through the lodepng include dir
set(LOADPNG_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bimg/3rdparty")
# stb has no hook of its own; bimg_decode and bimg_encode both use the tinyexr include dir
set(TINYEXR_INCLUDE_DIR "${Stb_INCLUDE_DIR}")
