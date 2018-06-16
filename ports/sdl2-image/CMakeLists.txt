cmake_minimum_required(VERSION 2.6)
project(SDL2_image C)

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
    version.rc
)

set_target_properties(SDL2_image PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)

# enable all file formats which are supported natively
foreach(FORMAT BMP GIF LBM PCX PNM TGA XPM XCF XV SVG)
    add_definitions(-DLOAD_${FORMAT})
endforeach(FORMAT)

find_package(SDL2 CONFIG REQUIRED)
find_package(PNG REQUIRED)

find_path(SDL2_INNER_HEADERS NAMES SDL2/SDL_endian.h)
include_directories(${CMAKE_SOURCE_DIR} ${SDL2_INNER_HEADERS}/SDL2)

add_definitions(-DLOAD_PNG -DLOAD_JPG -DLOAD_TIF -DLOAD_WEBP)
target_link_libraries(
    SDL2_image
    PUBLIC SDL2::SDL2
    PRIVATE PNG::PNG
)
if(USE_JPEG)
    find_package(JPEG REQUIRED)
    target_link_libraries(SDL2_image PRIVATE ${JPEG_LIBRARIES})
    target_compile_definitions(SDL2_image PRIVATE -DLOAD_JPG)
endif()
if(USE_TIFF)
    find_package(TIFF REQUIRED)
    target_link_libraries(SDL2_image PRIVATE ${TIFF_LIBRARIES})
    target_compile_definitions(SDL2_image PRIVATE -DLOAD_TIF)
endif()
if(USE_WEBP)
    find_package(WebP REQUIRED)
    target_link_libraries(SDL2_image PRIVATE ${WEBP_LIBRARIES})
    target_compile_definitions(SDL2_image PRIVATE -DLOAD_WEBP)
endif()

install(
    TARGETS SDL2_image
    EXPORT sdl2-image
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(FILES SDL_image.h DESTINATION include/SDL2 CONFIGURATIONS Release)
install(
    EXPORT sdl2-image
    NAMESPACE unofficial::sdl2-image::
    FILE unofficial-sdl2-image-targets.cmake
    DESTINATION share/unofficial-sdl2-image
)
