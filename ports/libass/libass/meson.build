src_intel = files(
    'x86/rasterizer.asm',
    'x86/blend_bitmaps.asm',
    'x86/blur.asm',
    'x86/be_blur.asm',
    'x86/cpuid.asm'
)
src_fontconfig = files('ass_fontconfig.c')
src_directwrite = files('ass_directwrite.c')
src_coretext = files('ass_coretext.c')

libass_src = files(
    'ass.c',
    'ass_utils.c',
    'ass_string.c',
    'ass_strtod.c',
    'ass_library.c',
    'ass_cache.c',
    'ass_font.c',
    'ass_fontselect.c',
    'ass_render.c',
    'ass_render_api.c',
    'ass_parse.c',
    'ass_shaper.c',
    'ass_outline.c',
    'ass_drawing.c',
    'ass_rasterizer.c',
    'ass_rasterizer_c.c',
    'ass_bitmap.c',
    'ass_blur.c'
)

libass_headers = files(
    'ass.h',
    'ass_types.h'
)

if fontconfig
    libass_src += src_fontconfig
endif
if directwrite
    libass_src += src_directwrite
endif
if coretext
    libass_src += src_coretext
endif

if enable_asm
    libass_src += nasm_gen.process(src_intel)
endif

libass = library('ass', libass_src, config_h,
                 vs_module_defs: 'libass.def',
                 install: true,
                 include_directories: incs,
                 dependencies: deps)

libass_dep = declare_dependency(link_with: libass,
                                include_directories: incs,
                                dependencies: deps,
                                sources: config_h)

install_headers(libass_headers, subdir: 'ass')
subdir('ass')
