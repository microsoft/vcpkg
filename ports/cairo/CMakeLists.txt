cmake_minimum_required(VERSION 3.11)
project(cairo C)

# Add include directories
include_directories(".")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  include_directories("./win32")
endif()

file(GLOB SOURCES
"cairo-analysis-surface.c"
"cairo-arc.c"
"cairo-array.c"
"cairo-atomic.c"
"cairo-base64-stream.c"
"cairo-base85-stream.c"
"cairo-bentley-ottmann.c"
"cairo-bentley-ottmann-rectangular.c"
"cairo-bentley-ottmann-rectilinear.c"
"cairo-botor-scan-converter.c"
"cairo-boxes.c"
"cairo-boxes-intersect.c"
"cairo.c"
"cairo-cache.c"
"cairo-clip.c"
"cairo-clip-boxes.c"
"cairo-clip-polygon.c"
"cairo-clip-region.c"
"cairo-clip-surface.c"
"cairo-color.c"
"cairo-composite-rectangles.c"
"cairo-compositor.c"
"cairo-contour.c"
"cairo-damage.c"
"cairo-debug.c"
"cairo-default-context.c"
"cairo-device.c"
"cairo-error.c"
"cairo-fallback-compositor.c"
"cairo-fixed.c"
"cairo-font-face.c"
"cairo-font-face-twin.c"
"cairo-font-face-twin-data.c"
"cairo-font-options.c"
"cairo-freelist.c"
"cairo-freed-pool.c"
"cairo-gstate.c"
"cairo-hash.c"
"cairo-hull.c"
"cairo-image-compositor.c"
"cairo-image-info.c"
"cairo-image-source.c"
"cairo-image-surface.c"
"cairo-line.c"
"cairo-lzw.c"
"cairo-matrix.c"
"cairo-mask-compositor.c"
"cairo-mesh-pattern-rasterizer.c"
"cairo-mempool.c"
"cairo-misc.c"
"cairo-mono-scan-converter.c"
"cairo-mutex.c"
"cairo-no-compositor.c"
"cairo-observer.c"
"cairo-output-stream.c"
"cairo-paginated-surface.c"
"cairo-path-bounds.c"
"cairo-path.c"
"cairo-path-fill.c"
"cairo-path-fixed.c"
"cairo-path-in-fill.c"
"cairo-path-stroke.c"
"cairo-path-stroke-boxes.c"
"cairo-path-stroke-polygon.c"
"cairo-path-stroke-traps.c"
"cairo-path-stroke-tristrip.c"
"cairo-pattern.c"
"cairo-pen.c"
"cairo-polygon.c"
"cairo-polygon-intersect.c"
"cairo-polygon-reduce.c"
"cairo-raster-source-pattern.c"
"cairo-recording-surface.c"
"cairo-rectangle.c"
"cairo-rectangular-scan-converter.c"
"cairo-region.c"
"cairo-rtree.c"
"cairo-scaled-font.c"
"cairo-shape-mask-compositor.c"
"cairo-slope.c"
"cairo-spans.c"
"cairo-spans-compositor.c"
"cairo-spline.c"
"cairo-stroke-dash.c"
"cairo-stroke-style.c"
"cairo-surface.c"
"cairo-surface-clipper.c"
"cairo-surface-fallback.c"
"cairo-surface-observer.c"
"cairo-surface-offset.c"
"cairo-surface-snapshot.c"
"cairo-surface-subsurface.c"
"cairo-surface-wrapper.c"
"cairo-time.c"
"cairo-tor-scan-converter.c"
"cairo-tor22-scan-converter.c"
"cairo-clip-tor-scan-converter.c"
"cairo-tag-attributes.c"
"cairo-tag-stack.c"
"cairo-toy-font-face.c"
"cairo-traps.c"
"cairo-tristrip.c"
"cairo-traps-compositor.c"
"cairo-unicode.c"
"cairo-user-font.c"
"cairo-version.c"
"cairo-wideint.c"
# generic font support
"cairo-cff-subset.c"
"cairo-scaled-font-subsets.c"
"cairo-truetype-subset.c"
"cairo-type1-fallback.c"
"cairo-type1-glyph-names.c"
"cairo-type1-subset.c"
"cairo-type3-glyph-surface.c"
# pdf
"cairo-pdf-interchange.c"
"cairo-pdf-operators.c"
"cairo-pdf-shading.c"
"cairo-pdf-surface.c"
# png
"cairo-png.c"
# ps surface
"cairo-ps-surface.c"
# deflate source
"cairo-deflate-stream.c"
# svg surface
"cairo-svg-surface.c"
# script surface
"cairo-script-surface.c"
# fontconfig + freetype
"cairo-ft-font.c"
)

# win32
file(GLOB PLATFORM_SOURCES_WIN32
"win32/cairo-win32-debug.c"
"win32/cairo-win32-device.c"
"win32/cairo-win32-gdi-compositor.c"
"win32/cairo-win32-system.c"
"win32/cairo-win32-surface.c"
"win32/cairo-win32-display-surface.c"
"win32/cairo-win32-printing-surface.c"
"win32/cairo-win32-font.c"
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  list(APPEND SOURCES ${PLATFORM_SOURCES_WIN32})
endif()

set(CMAKE_DEBUG_POSTFIX "d")

find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(Freetype REQUIRED)
find_package(unofficial-glib CONFIG REQUIRED)
find_package(unofficial-fontconfig CONFIG REQUIRED)
find_package(unofficial-pixman CONFIG REQUIRED)

# Cairo needs to be told which features of FreeType are availible
add_definitions(
    -DHAVE_FT_GLYPHSLOT_EMBOLDEN=1
    -DHAVE_FT_LIBRARY_SETLCDFILTER=1
    -DHAVE_FT_GLYPHSLOT_OBLIQUE=1
    -DHAVE_FT_LOAD_SFNT_TABLE=1
    -DHAVE_FT_GET_X11_FONT_FORMAT=1)

# additional features for macOS
if((CMAKE_SYSTEM_NAME STREQUAL "Darwin") OR (CMAKE_SYSTEM_NAME STREQUAL "Linux"))
  add_definitions(
      -DHAVE_INTTYPES_H=1
      -DHAVE_STDINT_H=1
      -DHAVE_SYS_TYPES_H=1
      -DHAVE_UINT64_T=1
      -DHAVE_UNISTD_H=1
      -DCAIRO_HAS_PTHREAD=1
      -DCAIRO_HAS_REAL_PTHREAD=1)
endif()

add_library(cairo ${SOURCES})

if (WITH_X11)
    target_compile_definitions(cairo PUBLIC -DCAIRO_HAS_XLIB_SURFACE=1)
endif()

target_link_libraries(cairo PRIVATE ZLIB::ZLIB PNG::PNG Freetype::Freetype unofficial::pixman::pixman-1 unofficial::fontconfig::fontconfig)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(cairo PRIVATE gdi32 msimg32 user32)
endif()

# GObject support module

set(CAIRO_GOBJECT_SOURCES
    "../util/cairo-gobject/cairo-gobject-enums.c"
    "../util/cairo-gobject/cairo-gobject-structs.c")

# GObject support sources do not include header with export macro
if(BUILD_SHARED_LIBS)
    set_source_files_properties(
        "../util/cairo-gobject/cairo-gobject-enums.c"
        "../util/cairo-gobject/cairo-gobject-structs.c"
        PROPERTIES COMPILE_DEFINITIONS "cairo_public=__declspec(dllexport)")
endif()

add_library(cairo-gobject ${CAIRO_GOBJECT_SOURCES}) 
target_link_libraries(cairo-gobject PRIVATE cairo unofficial::glib::gobject unofficial::glib::glib)

if(MSVC)
    # cairo produces a lot of warnings which are disabled here because they otherwise fill up the log files
    # NOTE: options only available to MSVC, clang in macOS doesn't understand these flags
    target_compile_options(cairo PRIVATE
        "/wd4244" "/wd4146" "/wd4312" "/wd4267" "/wd4996" "/wd4311" "/wd4334" "/wd4101"
    )
    target_compile_options(cairo-gobject PRIVATE
        "/wd4244" "/wd4146" "/wd4312" "/wd4267" "/wd4996" "/wd4311" "/wd4334" "/wd4101"
    )
endif()

if (CAIRO_HAS_XLIB_SURFACE)
    file(INSTALL cairo-xlib.h DESTINATION include)
endif()

install(TARGETS cairo cairo-gobject
    EXPORT cairo-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT cairo-targets
    NAMESPACE unofficial::cairo::
    FILE unofficial-cairo-targets.cmake
    DESTINATION share/unofficial-cairo
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/unofficial-cairo-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(PNG)
find_dependency(Freetype)
find_dependency(unofficial-glib CONFIG)
find_dependency(unofficial-fontconfig CONFIG)
find_dependency(unofficial-pixman CONFIG)

include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-cairo-targets.cmake)
")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-cairo-config.cmake DESTINATION share/unofficial-cairo)
