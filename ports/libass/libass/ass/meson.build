# Hack to work around https://github.com/mesonbuild/meson/issues/2546
foreach header: libass_headers
    configure_file(copy: true, input: header, output: '@PLAINNAME@')
endforeach
