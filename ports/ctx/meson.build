project(
  'ctx',
  'c',
  version : '0.1.14',
  meson_version : '>=0.63.0',
  default_options : [
    'c_std=c99',
  ],
)

pkg = import('pkgconfig')

is_windows = host_machine.system() == 'windows'
cpu_family = host_machine.cpu_family()
is_wasm = host_machine.system() == 'emscripten' or cpu_family == 'wasm32' or cpu_family == 'wasm64'

cli_opt = get_option('cli')
build_cli = not is_windows
if cli_opt.enabled()
  build_cli = true
elif cli_opt.disabled()
  build_cli = false
endif

babl_dep = dependency('babl-0.1', required : get_option('babl'))
harfbuzz_dep = dependency('harfbuzz', required : get_option('harfbuzz'))
curl_dep = dependency('libcurl', required : get_option('libcurl'))
sdl_dep = dependency('sdl2', required : get_option('sdl'))
thread_dep = dependency('threads')

ctx_deps = [thread_dep]
foreach dep : [babl_dep, harfbuzz_dep, curl_dep, sdl_dep]
  if dep.found()
    ctx_deps += dep
  endif
endforeach

ctx_conf = configuration_data()
ctx_conf.set10('CTX_SDL', sdl_dep.found())
ctx_conf.set10('CTX_BABL', babl_dep.found())
ctx_conf.set10('CTX_ENABLE_CM', babl_dep.found())
ctx_conf.set10('CTX_AUDIO', false)
ctx_conf.set10('CTX_VT', build_cli)
ctx_conf.set10('CTX_SCREENSHOT', build_cli)
ctx_conf.set10('CTX_BRAILLE_TEXT', build_cli)
ctx_conf.set10('CTX_ENABLE_CMYK', true)
ctx_conf.set10('CTX_PDF', build_cli)
ctx_conf.set10('CTX_SOCKETS', build_cli)
ctx_conf.set10('CTX_INLINED_NORMAL', true)
ctx_conf.set10('CTX_STATIC_FONTS', build_cli)
ctx_conf.set10('CTX_FRAGMENT_SPECIALIZE', true)
ctx_conf.set10('CTX_FAST_FILL_RECT', true)
ctx_conf.set10('CTX_RASTERIZER_SWITCH_DISPATCH', true)
ctx_conf.set10('CTX_FONTS_FROM_FILE', build_cli)
ctx_conf.set10('CTX_FONT_ENGINE_CTX_FS', false)
ctx_conf.set10('CTX_TERM', build_cli)
ctx_conf.set10('CTX_TERMIMG', build_cli)
ctx_conf.set10('CTX_PTY', build_cli)
ctx_conf.set10('CTX_DITHER', false)
ctx_conf.set10('CTX_CSS', build_cli)
ctx_conf.set10('CTX_EVENTS', build_cli)
ctx_conf.set10('CTX_NET', build_cli)
ctx_conf.set10('CTX_RASTERIZER', true)
ctx_conf.set10('CTX_PARSER', build_cli)
ctx_conf.set10('CTX_FORMATTER', build_cli)
ctx_conf.set10('CTX_CURL', curl_dep.found())
ctx_conf.set10('CTX_ALSA', false)
ctx_conf.set10('CTX_KMS', false)
ctx_conf.set10('CTX_FB', false)

configure_file(
  output : 'local.conf',
  configuration : ctx_conf,
)

ctx_c_args = [
  '-DCTX_SIMD=0',
  '-DCTX_PL_MPEG=' + (build_cli ? '1' : '0'),
  '-DCTX_STB_IMAGE=1',
  '-DCTX_IMAGE_WRITE=' + (build_cli ? '1' : '0'),
  '-DCTX_HARFBUZZ=' + (harfbuzz_dep.found() ? '1' : '0'),
]

if cpu_family == 'x86_64' and not is_windows
  ctx_c_args += ['-DCTX_X86_64']
elif cpu_family == 'arm'
  ctx_c_args += ['-DCTX_ARMV7L']
endif

if is_windows
  ctx_c_args += ['-D_USE_MATH_DEFINES']
  ctx_c_args += ['-D__restrict__=__restrict']
endif

ctx_inc = include_directories(
  '.',
  'bin',
  'bin/ui',
  'deps',
  'fonts',
)

ctx_lib = library(
  'ctx',
  'ctx.c',
  version : meson.project_version(),
  soversion : '0',
  dependencies : ctx_deps,
  include_directories : ctx_inc,
  c_args : ctx_c_args,
  install : true,
)

install_headers('ctx.h')

pkg.generate(
  ctx_lib,
  filebase : 'ctx',
  name : 'ctx',
  description : 'ctx vector graphics',
  version : meson.project_version(),
)

if is_wasm
  pc_conf = configuration_data()
  pc_conf.set('prefix', get_option('prefix'))
  pc_conf.set('libdir', join_paths(get_option('prefix'), get_option('libdir')))
  pc_conf.set('includedir', join_paths(get_option('prefix'), get_option('includedir')))
  pc_conf.set('version', meson.project_version())

  ctx_wasm_pc = configure_file(
    input : 'ctx-wasm.pc.in',
    output : 'ctx-wasm.pc',
    configuration : pc_conf,
  )

  ctx_wasm_simd_pc = configure_file(
    input : 'ctx-wasm-simd.pc.in',
    output : 'ctx-wasm-simd.pc',
    configuration : pc_conf,
  )

  install_data(
    [ctx_wasm_pc, ctx_wasm_simd_pc],
    install_dir : join_paths(get_option('libdir'), 'pkgconfig'),
  )
endif

if build_cli
  executable(
    'ctx',
    'bin/ctx.c',
    dependencies : ctx_deps,
    include_directories : ctx_inc,
    c_args : ctx_c_args,
    link_with : ctx_lib,
    install : true,
  )

  install_data(
    [
      'meta/graphics.ctx.terminal.appdata.xml',
      'meta/graphics.ctx.terminal.desktop',
      'meta/graphics.ctx.terminal.svg',
    ],
    install_dir : join_paths(get_option('datadir'), 'ctx'),
  )
endif
