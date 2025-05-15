vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF "${VERSION}"
    SHA512 5ca978cad5a661b081528be0fa74e199115c186afa1a0c9f55a9238fb2b452b680e75e8721a54077b9f4d717da5ef5801c359a0a89a5a02056caea067adab88f
    HEAD_REF main
    PATCHES
        fix-clang-cl.patch
        fix-bz2-windows-debug-dependency.patch
        fix-multiple-def.patch
        x264-api-imports.diff
        duplicate-unused.diff
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(NASM)

# gstreamer/meson tends to pick host modules (e.g. libdrm),
# so clean the search root unless explicitly set externally.
if(VCPKG_CROSSCOMPILING AND "$ENV{PKG_CONFIG}$ENV{PKG_CONFIG_LIBDIR}" STREQUAL "")
    set(ENV{PKG_CONFIG_LIBDIR} "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
endif()

if(VCPKG_TARGET_IS_OSX)
    # In Darwin platform, there can be an old version of `bison`,
    # Which can't be used for `gst-build`. It requires 2.4+
    execute_process(
        COMMAND ${BISON} --version
        OUTPUT_VARIABLE BISON_OUTPUT
    )
    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" BISON_VERSION "${BISON_OUTPUT}")
    set(BISON_MAJOR ${CMAKE_MATCH_1})
    set(BISON_MINOR ${CMAKE_MATCH_2})
    message(STATUS "Using bison: ${BISON_MAJOR}.${BISON_MINOR}.${CMAKE_MATCH_3}")
    if(NOT (BISON_MAJOR GREATER_EQUAL 2 AND BISON_MINOR GREATER_EQUAL 4))
        message(WARNING "'bison' upgrade is required. Please check the https://stackoverflow.com/a/35161881")
    endif()
endif()

# General features
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ges             ges
        gpl             gpl
        libav           libav
        nls             nls

        plugins-base    base
        alsa            gst-plugins-base:alsa
        gl              gst-plugins-base:gl
        gl-graphene     gst-plugins-base:gl-graphene
        ogg             gst-plugins-base:ogg
        opus-base       gst-plugins-base:opus
        pango           gst-plugins-base:pango
        vorbis          gst-plugins-base:vorbis
        x11             gst-plugins-base:x11
        x11             gst-plugins-base:xshm

        plugins-good    good
        bzip2           gst-plugins-good:bz2
        cairo           gst-plugins-good:cairo
        flac            gst-plugins-good:flac
        gdk-pixbuf      gst-plugins-good:gdk-pixbuf
        jpeg            gst-plugins-good:jpeg
        mpg123          gst-plugins-good:mpg123
        png             gst-plugins-good:png
        speex           gst-plugins-good:speex
        taglib          gst-plugins-good:taglib
        vpx             gst-plugins-good:vpx

        plugins-ugly    ugly
        x264            gst-plugins-ugly:x264

        plugins-bad     bad
        aes             gst-plugins-bad:aes
        aom             gst-plugins-bad:aom
        asio            gst-plugins-bad:asio
        assrender       gst-plugins-bad:assrender
        bzip2           gst-plugins-bad:bz2
        chromaprint     gst-plugins-bad:chromaprint
        closedcaption   gst-plugins-bad:closedcaption
        colormanagement gst-plugins-bad:colormanagement
        dash            gst-plugins-bad:dash
        dc1394          gst-plugins-bad:dc1394
        dtls            gst-plugins-bad:dtls
        faad            gst-plugins-bad:faad
        fdkaac          gst-plugins-bad:fdkaac
        fluidsynth      gst-plugins-bad:fluidsynth
        gl              gst-plugins-bad:gl
        libde265        gst-plugins-bad:libde265
        microdns        gst-plugins-bad:microdns
        modplug         gst-plugins-bad:modplug
        nvcodec         gst-plugins-bad:nvcodec
        openal          gst-plugins-bad:openal
        openh264        gst-plugins-bad:openh264
        openjpeg        gst-plugins-bad:openjpeg
        openmpt         gst-plugins-bad:openmpt
        opus-bad        gst-plugins-bad:opus
        smoothstreaming gst-plugins-bad:smoothstreaming
        sndfile         gst-plugins-bad:sndfile
        soundtouch      gst-plugins-bad:soundtouch
        srt             gst-plugins-bad:srt
        srtp            gst-plugins-bad:srtp
        vulkan          gst-plugins-bad:vulkan
        wayland         gst-plugins-bad:wayland
        webp            gst-plugins-bad:webp
        webrtc          gst-plugins-bad:webrtc
        wildmidi        gst-plugins-bad:wildmidi
        x11             gst-plugins-bad:x11
        x265            gst-plugins-bad:x265
)

string(REPLACE "OFF" "disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

# Align with dependencies of feature gl.
if(NOT "gl" IN_LIST FEATURES)
    set(PLUGIN_BASE_GL_API "")
    set(PLUGIN_BASE_WINDOW_SYSTEM "")
    set(PLUGIN_BASE_GL_PLATFORM "")
elseif(VCPKG_TARGET_IS_ANDROID)
    set(PLUGIN_BASE_GL_API gles2)
    set(PLUGIN_BASE_WINDOW_SYSTEM android,egl)
    set(PLUGIN_BASE_GL_PLATFORM egl)
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BASE_GL_API opengl)
    set(PLUGIN_BASE_WINDOW_SYSTEM win32)
    set(PLUGIN_BASE_GL_PLATFORM wgl)
else()
    set(PLUGIN_BASE_GL_API opengl)
    set(PLUGIN_BASE_WINDOW_SYSTEM auto)
    set(PLUGIN_BASE_GL_PLATFORM auto)
endif()

if("asio" IN_LIST FEATURES)
    set(PLUGIN_BAD_ASIO_SDK_PATH ${CURRENT_INSTALLED_DIR}/include/asiosdk)
else()
    set(PLUGIN_BAD_ASIO_SDK_PATH "")
endif()

#
# References
#   https://gitlab.freedesktop.org/gstreamer/gstreamer/-/blob/1.20.4/subprojects/gstreamer/meson_options.txt
#   https://gitlab.freedesktop.org/gstreamer/gstreamer/-/blob/1.20.4/subprojects/gst-plugins-base/meson_options.txt
#   https://gitlab.freedesktop.org/gstreamer/gstreamer/-/blob/1.20.4/subprojects/gst-plugins-good/meson_options.txt
#   https://gitlab.freedesktop.org/gstreamer/gstreamer/-/blob/1.20.4/subprojects/gst-plugins-ugly/meson_options.txt
#   https://gitlab.freedesktop.org/gstreamer/gstreamer/-/blob/1.20.4/subprojects/gst-plugins-bad/meson_options.txt
#
# Rationale for added options
#   Common options are added below systematically
#   Feature options are added below only if the feature needs an external dependency
#   Feature options that are dependent on the operating system type (like wasapi or osxaudio) are set to auto
#   Every other feature options are made available if the dependency is available on vcpkg and if the plugin has managed to build during tests
#

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}

        # General options
        -Dbuild-tools-source=system
        -Dpython=disabled
        -Dlibnice=disabled
        -Ddevtools=disabled
        -Drtsp_server=disabled
        -Dvaapi=disabled
        -Dsharp=disabled
        -Drs=disabled
        -Dgst-examples=disabled
        -Dtls=disabled
        -Dqt5=disabled
        # Common options
        -Dtests=disabled
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dorc=disabled # gstreamer requires a specific version of orc which is not available in vcpkg
        -Ddoc=disabled
        -Dgtk_doc=disabled
        # gstreamer
        -Dgstreamer:check=disabled
        -Dgstreamer:libunwind=disabled
        -Dgstreamer:libdw=disabled
        -Dgstreamer:dbghelp=disabled
        -Dgstreamer:bash-completion=disabled
        -Dgstreamer:coretracers=disabled
        -Dgstreamer:benchmarks=disabled
        -Dgstreamer:gst_debug=true
        -Dgstreamer:ptp-helper=disabled  # needs rustc toolchain setup
        # gst-plugins-base
        -Dgst-plugins-base:gl_api=${PLUGIN_BASE_GL_API}
        -Dgst-plugins-base:gl_winsys=${PLUGIN_BASE_WINDOW_SYSTEM}
        -Dgst-plugins-base:gl_platform=${PLUGIN_BASE_GL_PLATFORM}
        -Dgst-plugins-base:cdparanoia=disabled
        -Dgst-plugins-base:libvisual=disabled
        -Dgst-plugins-base:theora=disabled
        -Dgst-plugins-base:tremor=disabled
        -Dgst-plugins-base:xvideo=disabled
        # gst-plugins-good
        -Dgst-plugins-good:aalib=disabled
        -Dgst-plugins-good:directsound=auto
        -Dgst-plugins-good:dv=disabled
        -Dgst-plugins-good:dv1394=disabled
        -Dgst-plugins-good:gtk3=disabled # GTK version 3 only
        -Dgst-plugins-good:jack=disabled
        -Dgst-plugins-good:lame=disabled
        -Dgst-plugins-good:libcaca=disabled
        -Dgst-plugins-good:oss=disabled
        -Dgst-plugins-good:oss4=disabled
        -Dgst-plugins-good:osxaudio=auto
        -Dgst-plugins-good:osxvideo=auto
        -Dgst-plugins-good:pulse=disabled # Port pulseaudio depends on gstreamer
        -Dgst-plugins-good:qt5=disabled
        -Dgst-plugins-good:shout2=disabled
        #-Dgst-plugins-good:soup=disabled
        -Dgst-plugins-good:twolame=disabled
        -Dgst-plugins-good:waveform=auto
        -Dgst-plugins-good:wavpack=disabled # Error during plugin build
        # gst-plugins-ugly
        -Dgst-plugins-ugly:a52dec=disabled
        -Dgst-plugins-ugly:cdio=disabled
        -Dgst-plugins-ugly:dvdread=disabled
        -Dgst-plugins-ugly:mpeg2dec=disabled # libmpeg2 not found
        -Dgst-plugins-ugly:sidplay=disabled
        # gst-plugins-bad
        -Dgst-plugins-bad:avtp=disabled
        -Dgst-plugins-bad:androidmedia=auto
        -Dgst-plugins-bad:applemedia=auto
        -Dgst-plugins-bad:asio-sdk-path=${PLUGIN_BAD_ASIO_SDK_PATH}
        -Dgst-plugins-bad:bluez=disabled
        -Dgst-plugins-bad:bs2b=disabled
        -Dgst-plugins-bad:curl=disabled # Error during plugin build
        -Dgst-plugins-bad:curl-ssh2=disabled
        -Dgst-plugins-bad:d3dvideosink=auto
        -Dgst-plugins-bad:d3d11=auto
        -Dgst-plugins-bad:decklink=disabled
        -Dgst-plugins-bad:directfb=disabled
        -Dgst-plugins-bad:directsound=auto
        -Dgst-plugins-bad:dts=disabled
        -Dgst-plugins-bad:dvb=auto
        -Dgst-plugins-bad:faac=disabled
        -Dgst-plugins-bad:fbdev=auto
        -Dgst-plugins-bad:flite=disabled
        -Dgst-plugins-bad:gl=auto
        -Dgst-plugins-bad:gme=disabled
        -Dgst-plugins-bad:gs=disabled # Error during plugin configuration (abseil pkg-config file missing)
        -Dgst-plugins-bad:gsm=disabled
        -Dgst-plugins-bad:ipcpipeline=auto
        -Dgst-plugins-bad:iqa=disabled
        -Dgst-plugins-bad:kms=disabled
        -Dgst-plugins-bad:ladspa=disabled
        -Dgst-plugins-bad:ldac=disabled
        -Dgst-plugins-bad:lv2=disabled # Error during plugin configuration (lilv pkg-config file missing)
        -Dgst-plugins-bad:mediafoundation=auto
        -Dgst-plugins-bad:mpeg2enc=disabled
        -Dgst-plugins-bad:mplex=disabled
        -Dgst-plugins-bad:msdk=disabled
        -Dgst-plugins-bad:musepack=disabled
        -Dgst-plugins-bad:neon=disabled
        -Dgst-plugins-bad:onnx=disabled # libonnxruntime not found
        -Dgst-plugins-bad:openaptx=disabled
        -Dgst-plugins-bad:opencv=disabled # opencv not found
        -Dgst-plugins-bad:openexr=disabled # OpenEXR::IlmImf target not found
        -Dgst-plugins-bad:openni2=disabled # libopenni2 not found
        -Dgst-plugins-bad:opensles=disabled
        -Dgst-plugins-bad:qroverlay=disabled
        -Dgst-plugins-bad:resindvd=disabled
        -Dgst-plugins-bad:rsvg=disabled # librsvg-2.0 not found
        -Dgst-plugins-bad:rtmp=disabled # librtmp not found
        -Dgst-plugins-bad:sbc=disabled
        -Dgst-plugins-bad:sctp=auto
        -Dgst-plugins-bad:shm=disabled
        -Dgst-plugins-bad:spandsp=disabled
        -Dgst-plugins-bad:svthevcenc=disabled
        -Dgst-plugins-bad:teletext=disabled
        -Dgst-plugins-bad:tinyalsa=disabled
        -Dgst-plugins-bad:transcode=disabled
        -Dgst-plugins-bad:ttml=disabled
        -Dgst-plugins-bad:uvch264=disabled
        -Dgst-plugins-bad:va=disabled
        -Dgst-plugins-bad:voaacenc=disabled
        -Dgst-plugins-bad:voamrwbenc=disabled
        -Dgst-plugins-bad:wasapi=auto
        -Dgst-plugins-bad:wasapi2=auto
        -Dgst-plugins-bad:wayland=auto
        -Dgst-plugins-bad:winks=disabled
        -Dgst-plugins-bad:winscreencap=auto
        -Dgst-plugins-bad:zbar=disabled # Error during plugin build
        -Dgst-plugins-bad:zxing=disabled # Error during plugin build
        -Dgst-plugins-bad:wpe=disabled
        -Dgst-plugins-bad:magicleap=disabled
        -Dgst-plugins-bad:v4l2codecs=disabled
        -Dgst-plugins-bad:isac=disabled
    OPTIONS_RELEASE
        -Dgobject-cast-checks=disabled
        -Dglib-asserts=disabled
        -Dglib-checks=disabled
        -Dgstreamer:extra-checks=disabled
    ADDITIONAL_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        nasm='${NASM}'
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        glslc='${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc/glslc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KHR"
                    "${CURRENT_PACKAGES_DIR}/include/GL"
)

if("gl" IN_LIST FEATURES)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h"
                "${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h"
    )
endif()

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static") # AND tools
    list(APPEND GST_BIN_TOOLS
        gst-inspect-1.0
        gst-launch-1.0
        gst-stats-1.0
        gst-typefind-1.0
    )
    list(APPEND GST_LIBEXEC_TOOLS
        gst-completion-helper
        gst-plugin-scanner
    )
    if("ges" IN_LIST FEATURES)
        list(APPEND GST_BIN_TOOLS
            ges-launch-1.0
        )
    endif()
    if("plugins-base" IN_LIST FEATURES)
        list(APPEND GST_BIN_TOOLS
            gst-device-monitor-1.0
            gst-discoverer-1.0
            gst-play-1.0
        )
    endif()
    if("plugins-bad" IN_LIST FEATURES)
        list(APPEND GST_BIN_TOOLS
            gst-transcoder-1.0
        )
    endif()
endif()


if(GST_BIN_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${GST_BIN_TOOLS} AUTO_CLEAN)
endif()

if(GST_LIBEXEC_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${GST_LIBEXEC_TOOLS} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/libexec/gstreamer-1.0" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/libexec"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/include"
                    "${CURRENT_PACKAGES_DIR}/libexec"
                    "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include"
                    "${CURRENT_PACKAGES_DIR}/share/gdb"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Move plugin pkg-config files
    file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(GLOB pc_files_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files_dbg} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/"
                        "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin"
                        "${CURRENT_PACKAGES_DIR}/bin"
    )
    set(PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
    set(SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}"
                "${CURRENT_PACKAGES_DIR}/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gstconfig.h" "!defined(GST_STATIC_COMPILATION)" "0")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # move plugins to ${prefix}/plugins/${PORT} instead of ${prefix}/lib/gstreamer-1.0
    if(NOT VCPKG_BUILD_TYPE)
        file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
                           "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb"
        )
        file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
    endif()
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
                       "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0" "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0")
    endif()

    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gstreamer-1.0.pc")
    if(EXISTS "${_file}")
        file(READ "${_file}" _contents)
        string(REPLACE [[toolsdir=${exec_prefix}/bin]] "toolsdir=\${prefix}/../tools/${PORT}" _contents "${_contents}")
        string(REPLACE [[pluginscannerdir=${libexecdir}/gstreamer-1.0]] "pluginscannerdir=\${prefix}/../tools/${PORT}" _contents "${_contents}")
        string(REPLACE [[pluginsdir=${libdir}/gstreamer-1.0]] "pluginsdir=\${prefix}/plugins/${PORT}" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endif()

    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gstreamer-1.0.pc")
    if(EXISTS "${_file}")
        file(READ "${_file}" _contents)
        string(REPLACE [[toolsdir=${exec_prefix}/bin]] "toolsdir=\${prefix}/tools/${PORT}" _contents "${_contents}")
        string(REPLACE [[pluginscannerdir=${libexecdir}/gstreamer-1.0]] "pluginscannerdir=\${prefix}/tools/${PORT}" _contents "${_contents}")
        string(REPLACE [[pluginsdir=${libdir}/gstreamer-1.0]] "pluginsdir=\${prefix}/plugins/${PORT}" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endif()
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gstreamer-gl-1.0.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gstreamer-gl-1.0.pc" [[-I${libdir}/gstreamer-1.0/include]] "")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gstreamer-gl-1.0.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gstreamer-gl-1.0.pc" [[-I${libdir}/gstreamer-1.0/include]] "")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
