cmake_minimum_required (VERSION 3.6)
project (graphicsmagick)

find_package(ZLIB REQUIRED)
find_package(BZip2 REQUIRED)
find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(TIFF REQUIRED)
find_package(Freetype REQUIRED)

add_definitions(-D_MAGICKLIB_ -D_WANDLIB_ -DMAGICK_IMPLEMENTATION)

if (BUILD_SHARED_LIBS)
    add_definitions(-D_DLL -DDLL)
endif ()

if (MSVC)
    add_definitions( -D_VISUALC_ -D_CRT_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
endif ()

if (WIN32)
    add_definitions(-DWIN32 -D_WIN32)
    add_definitions(-D_WIN32_WINNT=0x0501)
endif ()

include_directories(".")
include_directories("magick")
include_directories("Magick++")
include_directories("Magick++/lib")
include_directories("wand")
include_directories("jbig/libjbig")

file(READ "magick/magick_config.h.in" CONFIG_H)
string(REPLACE "#undef HasBZLIB" "#define HasBZLIB" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasJPEG" "#define HasJPEG" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasPNG" "#define HasPNG" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasTIFF" "#define HasTIFF" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasTTF" "#define HasTTF" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasTTF" "#define HasTTF" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HAVE_FT2BUILD_H" "#define HAVE_FT2BUILD_H" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasZLIB" "#define HasZLIB" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasJBIG" "#define HasJBIG" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HasWEBP" "#define HasWEBP" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef QuantumDepth" "#define QuantumDepth 16" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef restrict" "#define restrict" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef size_t" "/* #undef size_t */" CONFIG_H "${CONFIG_H}")
if (WIN32)
string(REPLACE "#undef HasWINGDI32" "#define HasWINGDI32" CONFIG_H "${CONFIG_H}")
else ()
string(REPLACE "#undef HAVE_VSNPRINTF" "#define HAVE_VSNPRINTF" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef MagickLibSubdir" "#define MagickLibSubdir \"magick\"" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef MagickLibConfigSubDir" "#define MagickLibConfigSubDir \"magick/config\"" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef MagickShareConfigSubDir" "#define MagickShareConfigSubDir \"magick/config\"" CONFIG_H "${CONFIG_H}")
string(REPLACE "#undef HAVE_STDINT_H" "#define HAVE_STDINT_H" CONFIG_H "${CONFIG_H}")
endif ()
file(WRITE "magick/magick_config.h" "${CONFIG_H}")

file(READ "magick/magick_config_api.h.in" CONFIG_API_H)
string(REPLACE "#undef QuantumDepth" "#define QuantumDepth 16" CONFIG_API_H "${CONFIG_API_H}")
string(REPLACE "#undef size_t" "/* #undef size_t */" CONFIG_API_H "${CONFIG_API_H}")
file(WRITE "magick/magick_config_api.h" "${CONFIG_API_H}")

add_library(graphicsmagick coders/art.c coders/avs.c
		coders/bmp.c coders/braille.c coders/cals.c coders/caption.c
		coders/cineon.c coders/clipboard.c coders/cmyk.c
		coders/cut.c coders/dcm.c coders/dcraw.c coders/dib.c
		coders/dps.c coders/dpx.c coders/emf.c coders/ept.c
		coders/fax.c coders/fits.c coders/fpx.c coders/gif.c
		coders/gradient.c coders/gray.c coders/histogram.c
		coders/hrz.c coders/html.c coders/icon.c coders/identity.c
		coders/info.c coders/jbig.c coders/jnx.c coders/jp2.c
		coders/jpeg.c coders/label.c coders/locale.c coders/logo.c
		coders/mac.c coders/map.c coders/mat.c coders/matte.c
		coders/meta.c coders/miff.c coders/mono.c coders/mpc.c
		coders/mpeg.c coders/mpr.c coders/msl.c coders/mtv.c
		coders/mvg.c coders/null.c coders/otb.c coders/palm.c
		coders/pcd.c coders/pcl.c coders/pcx.c coders/pdb.c
		coders/pdf.c coders/pict.c coders/pix.c coders/plasma.c
		coders/png.c coders/pnm.c coders/preview.c coders/ps.c
		coders/ps2.c coders/ps3.c coders/psd.c coders/pwp.c coders/rgb.c
		coders/rla.c coders/rle.c coders/sct.c coders/sfw.c coders/sgi.c
		coders/stegano.c coders/sun.c coders/svg.c coders/tga.c
		coders/tiff.c coders/tile.c coders/tim.c coders/topol.c
		coders/ttf.c coders/txt.c coders/uil.c coders/url.c
		coders/uyvy.c coders/vicar.c coders/vid.c coders/viff.c
		coders/wbmp.c coders/webp.c coders/wmf.c coders/wpg.c
		coders/x.c coders/xbm.c coders/xc.c coders/xcf.c
		coders/xpm.c coders/xtrn.c coders/xwd.c coders/yuv.c
		filters/analyze.c
		magick/analyze.c magick/animate.c magick/annotate.c magick/attribute.c
		magick/average.c magick/bit_stream.c magick/blob.c magick/cdl.c
		magick/channel.c magick/color.c magick/color_lookup.c magick/colormap.c
		magick/colorspace.c magick/command.c magick/compare.c magick/composite.c
		magick/compress.c magick/confirm_access.c magick/constitute.c magick/decorate.c
		magick/delegate.c magick/deprecate.c magick/describe.c magick/display.c magick/draw.c
		magick/effect.c magick/enhance.c magick/enum_strings.c magick/error.c magick/export.c
		magick/floats.c magick/fx.c magick/gem.c magick/gradient.c magick/hclut.c
		magick/image.c magick/import.c magick/list.c magick/locale.c magick/log.c
		magick/magic.c magick/magick.c magick/magick_endian.c magick/map.c
		magick/memory.c magick/module.c magick/monitor.c magick/montage.c magick/nt_base.c
		magick/nt_feature.c magick/omp_data_view.c magick/operator.c magick/paint.c
		magick/pixel_cache.c magick/pixel_iterator.c magick/plasma.c magick/PreRvIcccm.c
		magick/profile.c magick/quantize.c magick/random.c magick/registry.c magick/render.c
		magick/resize.c magick/resource.c magick/segment.c magick/semaphore.c
		magick/shear.c magick/signature.c magick/static.c magick/statistics.c
		magick/tempfile.c magick/texture.c magick/timer.c magick/transform.c
		magick/tsd.c magick/type.c magick/unix_port.c magick/utility.c
		magick/version.c magick/widget.c magick/xwindow.c
		Magick++/lib/Blob.cpp Magick++/lib/BlobRef.cpp Magick++/lib/CoderInfo.cpp
		Magick++/lib/Color.cpp Magick++/lib/Drawable.cpp Magick++/lib/Exception.cpp
		Magick++/lib/Functions.cpp Magick++/lib/Geometry.cpp Magick++/lib/Image.cpp
		Magick++/lib/ImageRef.cpp Magick++/lib/Montage.cpp Magick++/lib/Options.cpp
		Magick++/lib/Pixels.cpp Magick++/lib/STL.cpp Magick++/lib/Thread.cpp
		Magick++/lib/TypeMetric.cpp
		wand/drawing_wand.c wand/magick_compat.c wand/magick_wand.c wand/pixel_wand.c
		jbig/libjbig/jbig.c jbig/libjbig/jbig_ar.c jbig/libjbig/jbig85.c)

TARGET_LINK_LIBRARIES(graphicsmagick PRIVATE
    ZLIB::ZLIB
    BZip2::BZip2
    #${JPEG_LIBRARIES}
    JPEG::JPEG
    PNG::PNG
    TIFF::TIFF
    Freetype::Freetype
	WebP::webp WebP::webpdemux WebP::libwebpmux WebP::webpdecoder
)
target_include_directories(graphicsmagick INTERFACE $<INSTALL_INTERFACE:include>)

install(TARGETS graphicsmagick
    EXPORT graphicsmagick-targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(
    EXPORT graphicsmagick-targets
    FILE unofficial-graphicsmagick-targets.cmake
    NAMESPACE unofficial::graphicsmagick::
    DESTINATION share/unofficial-graphicsmagick
)
find_package(ZLIB REQUIRED)
find_package(BZip2 REQUIRED)
find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(TIFF REQUIRED)
find_package(Freetype REQUIRED)
find_package(WebP CONFIG REQUIRED)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/unofficial-graphicsmagick-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(BZip2)
find_dependency(JPEG)
find_dependency(PNG)
find_dependency(TIFF)
find_dependency(Freetype)
find_dependency(WebP)

include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-graphicsmagick-targets.cmake)
")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-graphicsmagick-config.cmake DESTINATION share/unofficial-graphicsmagick)

option(INSTALL_HEADERS "Install development header files" ON)

if (INSTALL_HEADERS)
    install(FILES magick/alpha_composite.h DESTINATION include/magick)
    install(FILES magick/analyze.h DESTINATION include/magick)
    install(FILES magick/api.h DESTINATION include/magick)
    install(FILES magick/attribute.h DESTINATION include/magick)
    install(FILES magick/average.h DESTINATION include/magick)
    install(FILES magick/bit_stream.h DESTINATION include/magick)
    install(FILES magick/blob.h DESTINATION include/magick)
    install(FILES magick/cdl.h DESTINATION include/magick)
    install(FILES magick/channel.h DESTINATION include/magick)
    install(FILES magick/color.h DESTINATION include/magick)
    install(FILES magick/colormap.h DESTINATION include/magick)
    install(FILES magick/colorspace.h DESTINATION include/magick)
    install(FILES magick/color_lookup.h DESTINATION include/magick)
    install(FILES magick/command.h DESTINATION include/magick)
    install(FILES magick/common.h DESTINATION include/magick)
    install(FILES magick/compare.h DESTINATION include/magick)
    install(FILES magick/composite.h DESTINATION include/magick)
    install(FILES magick/compress.h DESTINATION include/magick)
    install(FILES magick/confirm_access.h DESTINATION include/magick)
    install(FILES magick/constitute.h DESTINATION include/magick)
    install(FILES magick/decorate.h DESTINATION include/magick)
    install(FILES magick/delegate.h DESTINATION include/magick)
    install(FILES magick/deprecate.h DESTINATION include/magick)
    install(FILES magick/describe.h DESTINATION include/magick)
    install(FILES magick/draw.h DESTINATION include/magick)
    install(FILES magick/effect.h DESTINATION include/magick)
    install(FILES magick/enhance.h DESTINATION include/magick)
    install(FILES magick/enum_strings.h DESTINATION include/magick)
    install(FILES magick/error.h DESTINATION include/magick)
    install(FILES magick/floats.h DESTINATION include/magick)
    install(FILES magick/forward.h DESTINATION include/magick)
    install(FILES magick/fx.h DESTINATION include/magick)
    install(FILES magick/gem.h DESTINATION include/magick)
    install(FILES magick/gradient.h DESTINATION include/magick)
    install(FILES magick/hclut.h DESTINATION include/magick)
    install(FILES magick/image.h DESTINATION include/magick)
    install(FILES magick/list.h DESTINATION include/magick)
    install(FILES magick/locale_c.h DESTINATION include/magick)
    install(FILES magick/log.h DESTINATION include/magick)
    install(FILES magick/magic.h DESTINATION include/magick)
    install(FILES magick/magick.h DESTINATION include/magick)
    install(FILES magick/magick_config.h DESTINATION include/magick)
    install(FILES magick/magick_config_api.h DESTINATION include/magick)
    install(FILES magick/magick_endian.h DESTINATION include/magick)
    install(FILES magick/magick_types.h DESTINATION include/magick)
    install(FILES magick/map.h DESTINATION include/magick)
    install(FILES magick/memory.h DESTINATION include/magick)
    install(FILES magick/module.h DESTINATION include/magick)
    install(FILES magick/module_aliases.h DESTINATION include/magick)
    install(FILES magick/monitor.h DESTINATION include/magick)
    install(FILES magick/montage.h DESTINATION include/magick)
    install(FILES magick/nt_base.h DESTINATION include/magick)
    install(FILES magick/nt_feature.h DESTINATION include/magick)
    install(FILES magick/omp_data_view.h DESTINATION include/magick)
    install(FILES magick/operator.h DESTINATION include/magick)
    install(FILES magick/paint.h DESTINATION include/magick)
    install(FILES magick/pixel_cache.h DESTINATION include/magick)
    install(FILES magick/pixel_iterator.h DESTINATION include/magick)
    install(FILES magick/plasma.h DESTINATION include/magick)
    install(FILES magick/prefetch.h DESTINATION include/magick)
    install(FILES magick/PreRvIcccm.h DESTINATION include/magick)
    install(FILES magick/profile.h DESTINATION include/magick)
    install(FILES magick/quantize.h DESTINATION include/magick)
    install(FILES magick/random-private.h DESTINATION include/magick)
    install(FILES magick/random.h DESTINATION include/magick)
    install(FILES magick/registry.h DESTINATION include/magick)
    install(FILES magick/render.h DESTINATION include/magick)
    install(FILES magick/resize.h DESTINATION include/magick)
    install(FILES magick/resource.h DESTINATION include/magick)
    install(FILES magick/semaphore.h DESTINATION include/magick)
    install(FILES magick/shear.h DESTINATION include/magick)
    install(FILES magick/signature.h DESTINATION include/magick)
    install(FILES magick/spinlock.h DESTINATION include/magick)
    install(FILES magick/static.h DESTINATION include/magick)
    install(FILES magick/statistics.h DESTINATION include/magick)
    install(FILES magick/studio.h DESTINATION include/magick)
    install(FILES magick/symbols.h DESTINATION include/magick)
    install(FILES magick/tempfile.h DESTINATION include/magick)
    install(FILES magick/texture.h DESTINATION include/magick)
    install(FILES magick/timer.h DESTINATION include/magick)
    install(FILES magick/transform.h DESTINATION include/magick)
    install(FILES magick/tsd.h DESTINATION include/magick)
    install(FILES magick/type.h DESTINATION include/magick)
    install(FILES magick/unix_port.h DESTINATION include/magick)
    install(FILES magick/utility.h DESTINATION include/magick)
    install(FILES magick/version.h DESTINATION include/magick)
    install(FILES magick/widget.h DESTINATION include/magick)
    install(FILES magick/xwindow.h DESTINATION include/magick)

    install(FILES Magick++/lib/Magick++.h DESTINATION include)

    install(FILES Magick++/lib/Magick++/Blob.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/BlobRef.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/CoderInfo.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Color.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Drawable.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Exception.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Functions.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Geometry.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Image.h DESTINATION include/Magick++/)
    install(FILES Magick++/lib/Magick++/ImageRef.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Include.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Montage.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Options.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Pixels.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/STL.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/Thread.h DESTINATION include/Magick++)
    install(FILES Magick++/lib/Magick++/TypeMetric.h DESTINATION include/Magick++)

    install(FILES wand/drawing_wand.h DESTINATION include/wand)
    install(FILES wand/magick_wand.h DESTINATION include/wand)
    install(FILES wand/pixel_wand.h DESTINATION include/wand)
    install(FILES wand/wand_api.h DESTINATION include/wand)
    install(FILES wand/wand_private.h DESTINATION include/wand)
    install(FILES wand/wand_symbols.h DESTINATION include/wand)
endif ()
