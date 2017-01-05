cmake_minimum_required(VERSION 2.6)
project(SDL2_image)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_library(SDL_LIBRARY SDL2)

include_directories(${SDL_INCLUDE_DIR})
include_directories(${SDL_INCLUDE_DIR}/SDL2)
include_directories(${CMAKE_SOURCE_DIR})

#add_definitions(-DNOCONTROLS -DTHREADED_AUDIO)

# some c++ code just assumes memset is available

add_library(SDL2_image
    IMG.c
	IMG_bmp.c
	IMG_gif.c
	IMG_jpg.c
	IMG_lbm.c
	IMG_pcx.c
	IMG_png.c
	IMG_pnm.c
	IMG_tga.c
	IMG_tif.c
	IMG_webp.c
	IMG_xcf.c
	IMG_xpm.c
	IMG_xv.c
	IMG_xxx.c
	)

target_link_libraries(SDL2_image ${SDL_LIBRARY})

install(TARGETS SDL2_image
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(FILES SDL_image.h DESTINATION include CONFIGURATIONS Release)


message(STATUS "Link-time dependencies:")
message(STATUS "  " ${SDL_LIBRARY})
