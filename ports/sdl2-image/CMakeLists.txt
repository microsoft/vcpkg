cmake_minimum_required(VERSION 2.6)
project(SDL2_image C)

### configuration ###

# enable all file formats which are supported natively
set(SUPPORTED_FORMATS BMP GIF LBM PCX PNM TGA XPM XCF XV SVG)

# enable all file formats which are supported through external dependencies
option(USE_WEBP "Enable support for WebP format" OFF)
option(USE_PNG "Enable support for PNG format" OFF)
option(USE_JPEG "Enable support for JPEG format" OFF)
option(USE_TIFF "Enable support for TIFF format" OFF)

### implementation ###

add_library(SDL2_image
    IMG.c
    IMG_bmp.c
    IMG_gif.c
    IMG_jpg.c
    IMG_lbm.c
    IMG_pcx.c
    IMG_png.c
    IMG_pnm.c
    IMG_svg.c
    IMG_tga.c
    IMG_tif.c
    IMG_webp.c
    IMG_xcf.c
    IMG_xpm.c
    IMG_xv.c
    IMG_xxx.c
    IMG_WIC.c
    version.rc
    )

if (APPLE)
    target_sources(SDL2_image PRIVATE
        IMG_ImageIO.m
    )
    target_compile_options(SDL2_image BEFORE PRIVATE
        "-x" "objective-c"
    )
endif()

set_target_properties(SDL2_image PROPERTIES DEFINE_SYMBOL DLL_EXPORT)

foreach(FORMAT ${SUPPORTED_FORMATS})
    add_definitions(-DLOAD_${FORMAT})
endforeach(FORMAT)

# SDL
find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

include_directories(${SDL_INCLUDE_DIR})
include_directories(${SDL_INCLUDE_DIR}/SDL2)
include_directories(${CMAKE_SOURCE_DIR})

target_link_libraries(SDL2_image SDL2::SDL2)

# external dependencies
if(USE_WEBP)
    find_package(WebP CONFIG REQUIRED)
    add_definitions(-DLOAD_WEBP)
    target_link_libraries(SDL2_image PRIVATE WebP::webp)
endif()

if(USE_PNG)
    find_package(PNG REQUIRED)
    add_definitions(-DLOAD_PNG)
    target_link_libraries(SDL2_image PRIVATE PNG::PNG)
endif()

if(USE_JPEG)
    find_package(JPEG REQUIRED)
    add_definitions(-DLOAD_JPG)
    target_link_libraries(SDL2_image PRIVATE ${JPEG_LIBRARIES})
endif()

if(USE_TIFF)
    find_package(TIFF REQUIRED)
    add_definitions(-DLOAD_TIF)
    target_link_libraries(SDL2_image PRIVATE TIFF::TIFF)
    
    if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4996")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4996")
    endif()
endif()

install(TARGETS SDL2_image
    EXPORT SDL2_image
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(FILES SDL_image.h DESTINATION include/SDL2 CONFIGURATIONS Release)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/sdl2-image-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/sdl2-image-config.cmake" @ONLY
    INSTALL_DESTINATION "share/sdl2-image")

set(prefix "")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
set(PACKAGE "SDL2_image")
file(READ "SDL_image.h" header_contents)
#    #define SDL_IMAGE_MAJOR_VERSION 2
#    #define SDL_IMAGE_MINOR_VERSION 0
#    #define SDL_IMAGE_PATCHLEVEL    5
string(REGEX MATCH "define *SDL_IMAGE_MAJOR_VERSION *([0-9]+)" _ "${header_contents}")
set(VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "define *SDL_IMAGE_MINOR_VERSION *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
string(REGEX MATCH "define *SDL_IMAGE_PATCHLEVEL *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
set(SDL_VERSION 0.0)
configure_file(SDL2_image.pc.in "${CMAKE_CURRENT_BINARY_DIR}/SDL2_image.pc" @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SDL2_image.pc DESTINATION lib/pkgconfig)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sdl2-image-config.cmake DESTINATION share/sdl2-image)

install(EXPORT SDL2_image
    DESTINATION share/sdl2-image/
    FILE sdl2-image-targets.cmake
    NAMESPACE SDL2::
)
