project('libass', 'c', license: 'ISC',
        meson_version: '>= 0.55.0',
        # cpp_std specified because meson compiler options are currently global
        default_options: ['c_std=c99', 'cpp_std=c++11', 'buildtype=debugoptimized', 'warning_level=2'],
        version: '0.15.1')

conf = configuration_data()
deps = []

# Compiler setup

cc = meson.get_compiler('c')

if cc.get_argument_syntax() == 'gcc'
    cflags = [
        '-Wno-sign-compare',
        '-Wno-unused-parameter',
        '-Werror-implicit-function-declaration',
        '-Wstrict-prototypes',
        '-Wpointer-arith',
        '-Wredundant-decls',
        '-Wno-missing-field-initializers'
    ]
    add_project_arguments(cc.get_supported_arguments(cflags), language: 'c')
endif

test_args = []

if host_machine.system() == 'linux'
    test_args += '-D_GNU_SOURCE'
    add_project_arguments('-D_GNU_SOURCE', language: 'c')
elif host_machine.system() == 'darwin'
    test_args += '-D_DARWIN_C_SOURCE'
    add_project_arguments('-D_DARWIN_C_SOURCE', language: 'c')
elif cc.get_id() != 'msvc'
    test_args += '-D_POSIX_C_SOURCE=200809L'
    add_project_arguments('-D_POSIX_C_SOURCE=200809L', language: 'c')
endif

# Configuration

if get_option('large-tiles')
    conf.set('CONFIG_LARGE_TILES', 1)
endif

conf.set('PACKAGE_NAME', 'libass')
conf.set('PACKAGE_VERSION', meson.project_version())

conf.set('CONFIG_SOURCEVERSION', '"meson, on or after: ' + meson.project_version() + '"')

str_check_functions = [
    'strdup',
    'strndup'
]

foreach name: str_check_functions
    if cc.has_function(name) and cc.has_header_symbol('string.h', name, args: test_args)
        conf.set('HAVE_@0@'.format(name.to_upper()), 1)
    endif
endforeach

# Dependencies

m_dep = cc.find_library('m', required: false)
if m_dep.found()
    deps += m_dep
endif

iconv_dep = cc.find_library('iconv', required: false)
if iconv_dep.found()
    deps += iconv_dep
endif
if iconv_dep.found() or cc.has_function('iconv_open')
    conf.set('CONFIG_ICONV', 1)
endif

freetype_dep = dependency('freetype2', version: '>= 9.10.3')
if freetype_dep.found()
    deps += freetype_dep
    conf.set('CONFIG_FREETYPE', 1)
endif

if host_machine.system() == 'windows' and get_option('default_library') == 'static'
    add_project_arguments('-DFRIBIDI_LIB_STATIC', language: 'c')
endif
fribidi_dep = dependency('fribidi', version: '>= 0.19.0')
if fribidi_dep.found()
    deps += fribidi_dep
    conf.set('CONFIG_FRIBIDI', 1)
endif

harfbuzz_dep = dependency('harfbuzz', version: '>= 1.2.3', required: get_option('harfbuzz'))
if harfbuzz_dep.found()
    deps += harfbuzz_dep
    conf.set('CONFIG_HARFBUZZ', 1)
endif

req_fontconfig = get_option('fontconfig')

if host_machine.system() != 'windows' and host_machine.system() != 'darwin'
    req_fontconfig = get_option('fontconfig').disabled()
endif

fontconfig_dep = dependency('fontconfig', version: '>= 2.10.92', required: req_fontconfig)
fontconfig = false
if fontconfig_dep.found()
    deps += fontconfig_dep
    conf.set('CONFIG_FONTCONFIG', 1)
    fontconfig = true
endif

if get_option('test')
    deps += dependency('libpng', version: '>= 1.2.0')
    conf.set('CONFIG_LIBPNG', 1)
endif

# DirectWrite
directwrite = false
if host_machine.system() == 'windows' and not get_option('directwrite').disabled()
    if cc.has_header('windows.h')
        deps += cc.find_library('dwrite', required: true)
        conf.set('CONFIG_DIRECTWRITE', 1)
        directwrite = true
    elif get_option('directwrite').enabled()
        error('DirectWrite was enabled explicitly, but required header is missing.')
    endif
endif

# CoreText
coretext = false
if host_machine.system() == 'darwin' and not get_option('coretext').disabled()
    coretext_dep = dependency('appleframeworks', modules: ['CoreText', 'CoreFoundation'], required: false)
    if cc.has_type('CTRunRef', prefix: '#include <CoreText/CoreText.h>', dependencies: coretext_dep)
        deps += coretext_dep
        conf.set('CONFIG_CORETEXT', 1)
        coretext = true
    elif get_option('coretext').enabled()
        error('CoreText was enabled explicitly, but required headers or frameworks are missing.')
    endif
endif

if get_option('require-system-font-provider') and not fontconfig and not directwrite and not coretext
    error('''Either DirectWrite (on Windows), CoreText (on OSX), or Fontconfig (Linux, other) is required.
If you really want to compile without a system font provider, set -Drequire-system-font-provider=false''')
endif

# dirent.h
if host_machine.system() == 'windows' and not cc.has_header('dirent.h')
    error('dirent.h is needed for traversing directories.')
endif

# ASM

nasm_args = []
nasm = find_program('nasm', required: get_option('asm'))
enable_asm = nasm.found()

# NASM version check
if enable_asm
    nasm_r = run_command(nasm, '-v')
    out = nasm_r.stdout().strip().split()
    if out[1].to_lower() == 'version'
        if out[2].version_compare('< 2.10')
            warning('nasm is too old (found @0@); ASM functions are disabled.'.format(out[2]))
            enable_asm = false
        endif
    else
        warning('Unexpected nasm version string: @0@; disabling.'.format(nasm_r.stdout()))
        enable_asm = false
    endif
endif

# Architecture check - TODO x32
if host_machine.cpu_family() == 'x86'
    bittype = '32'
    nasm_args += '-DARCH_X86_64=0'
    intel = true
elif host_machine.cpu_family() == 'x86_64'
    bittype = '64'
    nasm_args += '-DARCH_X86_64=1'
    intel = true
else
    intel = false
endif

if enable_asm and not intel
    warning('ASM functions are not available on non-intel machines; disabling.')
    enable_asm = false
elif (not enable_asm) and intel
    warning('Install nasm-2.10 or later for a significantly faster libass build.')
endif

# System check
if enable_asm
    host_system = host_machine.system()
    if host_system == 'windows'
        nasm_args += ['-f', 'win' + bittype]
        if bittype == '32'
            nasm_args += '-DPREFIX'
        endif
    elif host_system == 'darwin'
        nasm_args += ['-f', 'macho' + bittype, '-DPREFIX', '-DSTACK_ALIGNMENT=16']
    elif host_system == 'linux' or host_system == 'sunos' or host_system == 'haiku'
        nasm_args += ['-f', 'elf' + bittype, '-DSTACK_ALIGNMENT=16']
    elif host_system == 'dragonfly' or host_system.endswith('bsd')
        nasm_args += ['-f', 'elf' + bittype]
    else
        warning('Please contact libass upstream to figure out if ASM support for your platform can be added. In the meantime, disabling.')
        enable_asm = false
    endif
endif

if enable_asm
    conf.set('CONFIG_ASM', 1)

    nasm_args += '-Dprivate_prefix=ass'
    nasm_args += ['-I', meson.current_source_dir() / 'libass' + '/', '-o', '@OUTPUT@', '@INPUT@']

    nasm_gen = generator(nasm, output: '@BASENAME@.o', arguments: nasm_args)
endif

config_h = configure_file(output: 'config.h', configuration: conf)

incs = include_directories('.', 'libass')

subdir('libass')
if get_option('test')
    subdir('test')
endif
if get_option('profile')
    subdir('profile')
endif

# libass.pc
pkg = import('pkgconfig')
pkg.generate(libass,
             name: 'libass',
             description: 'LibASS is an SSA/ASS subtitles rendering library')
