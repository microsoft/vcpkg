if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES
        plugin-base-disable-no-unused.patch
    )
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.20.5
    SHA512 2a996d8ac0f70c34dbbc02c875026df6e89346f0844fbaa25475075bcb6e57c81ceb7d71e729c3259eace851e3d7222cb3fe395e375d93eb45b1262a6ede1fdb
    HEAD_REF master
    PATCHES
        fix-clang-cl.patch
        fix-clang-cl-gstreamer.patch
        fix-clang-cl-base.patch
        fix-clang-cl-good.patch
        fix-clang-cl-bad.patch
        fix-clang-cl-ugly.patch
        gstreamer-disable-no-unused.patch
        srtp_fix.patch
        ${PATCHES}
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(NASM)

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

if("gpl" IN_LIST FEATURES)
    set(LICENSE_GPL enabled)
else()
    set(LICENSE_GPL disabled)
endif()

if("nls" IN_LIST FEATURES)
    set(NLS enabled)
else()
    set(NLS disabled)
endif()

if("plugins-base" IN_LIST FEATURES)
    set(PLUGIN_BASE_SUPPORT enabled)
else()
    set(PLUGIN_BASE_SUPPORT disabled)
endif()

if("plugins-good" IN_LIST FEATURES)
    set(PLUGIN_GOOD_SUPPORT enabled)
else()
    set(PLUGIN_GOOD_SUPPORT disabled)
endif()

if("plugins-ugly" IN_LIST FEATURES)
    set(PLUGIN_UGLY_SUPPORT enabled)
else()
    set(PLUGIN_UGLY_SUPPORT disabled)
endif()

if("plugins-bad" IN_LIST FEATURES)
    set(PLUGIN_BAD_SUPPORT enabled)
else()
    set(PLUGIN_BAD_SUPPORT disabled)
endif()

if("gl-graphene" IN_LIST FEATURES)
    set(GL_GRAPHENE enabled)
else()
    set(GL_GRAPHENE disabled)
endif()

# Base optional plugins

if(VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BASE_WINDOW_SYSTEM win32)
    set(PLUGIN_BASE_GL_PLATFORM wgl)
else()
    set(PLUGIN_BASE_WINDOW_SYSTEM auto)
    set(PLUGIN_BASE_GL_PLATFORM auto)
endif()

if("alsa" IN_LIST FEATURES AND VCPKG_TARGET_IS_LINUX)
    set(PLUGIN_BASE_ALSA enabled)
else()
    set(PLUGIN_BASE_ALSA disabled)
endif()

if("ogg" IN_LIST FEATURES)
    set(PLUGIN_BASE_OGG enabled)
else()
    set(PLUGIN_BASE_OGG disabled)
endif()

if("opus-base" IN_LIST FEATURES)
    set(PLUGIN_BASE_OPUS enabled)
else()
    set(PLUGIN_BASE_OPUS disabled)
endif()

if("pango" IN_LIST FEATURES)
    set(PLUGIN_BASE_PANGO enabled)
else()
    set(PLUGIN_BASE_PANGO disabled)
endif()

if("vorbis" IN_LIST FEATURES)
    set(PLUGIN_BASE_VORBIS enabled)
else()
    set(PLUGIN_BASE_VORBIS disabled)
endif()

if("x11-base" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BASE_X11 enabled)
else()
    set(PLUGIN_BASE_X11 disabled)
endif()

# Good optional plugins

if("cairo" IN_LIST FEATURES)
    set(PLUGIN_GOOD_CAIRO enabled)
else()
    set(PLUGIN_GOOD_CAIRO disabled)
endif()

if("flac" IN_LIST FEATURES)
    set(PLUGIN_GOOD_FLAC enabled)
else()
    set(PLUGIN_GOOD_FLAC disabled)
endif()

if("gdk-pixbuf" IN_LIST FEATURES)
    set(PLUGIN_GOOD_GDK_PIXBUF enabled)
else()
    set(PLUGIN_GOOD_GDK_PIXBUF disabled)
endif()

if("jpeg" IN_LIST FEATURES)
    set(PLUGIN_GOOD_JPEG enabled)
else()
    set(PLUGIN_GOOD_JPEG disabled)
endif()

if("mpg123" IN_LIST FEATURES)
    set(PLUGIN_GOOD_MPG123 enabled)
else()
    set(PLUGIN_GOOD_MPG123 disabled)
endif()

if("png" IN_LIST FEATURES)
    set(PLUGIN_GOOD_PNG enabled)
else()
    set(PLUGIN_GOOD_PNG disabled)
endif()

if("speex" IN_LIST FEATURES)
    set(PLUGIN_GOOD_SPEEX enabled)
else()
    set(PLUGIN_GOOD_SPEEX disabled)
endif()

if("taglib" IN_LIST FEATURES)
    set(PLUGIN_GOOD_TAGLIB enabled)
else()
    set(PLUGIN_GOOD_TAGLIB disabled)
endif()

if("vpx" IN_LIST FEATURES)
    set(PLUGIN_GOOD_VPX enabled)
else()
    set(PLUGIN_GOOD_VPX disabled)
endif()

# Ugly optional plugins

if("gpl" IN_LIST FEATURES AND "x264" IN_LIST FEATURES)
    set(PLUGIN_UGLY_X264 enabled)
else()
    set(PLUGIN_UGLY_X264 disabled)
endif()

# Bad optional plugins

if("aes" IN_LIST FEATURES)
    set(PLUGIN_BAD_AES enabled)
else()
    set(PLUGIN_BAD_AES disabled)
endif()

if("asio" IN_LIST FEATURES)
    set(PLUGIN_BAD_ASIO enabled)
    set(PLUGIN_BAD_ASIO_SDK_PATH ${CURRENT_INSTALLED_DIR}/include/asiosdk)
else()
    set(PLUGIN_BAD_ASIO disabled)
    set(PLUGIN_BAD_ASIO_SDK_PATH "")
endif()

if("assrender" IN_LIST FEATURES)
    set(PLUGIN_BAD_ASSRENDER enabled)
else()
    set(PLUGIN_BAD_ASSRENDER disabled)
endif()

if("chromaprint" IN_LIST FEATURES)
    set(PLUGIN_BAD_CHROMAPRINT enabled)
else()
    set(PLUGIN_BAD_CHROMAPRINT disabled)
endif()

if("closedcaption" IN_LIST FEATURES)
    set(PLUGIN_BAD_CLOSEDCAPTION enabled)
else()
    set(PLUGIN_BAD_CLOSEDCAPTION disabled)
endif()

if("colormanagement" IN_LIST FEATURES)
    set(PLUGIN_BAD_COLORMANAGEMENT enabled)
else()
    set(PLUGIN_BAD_COLORMANAGEMENT disabled)
endif()

if("dash" IN_LIST FEATURES)
    set(PLUGIN_BAD_DASH enabled)
else()
    set(PLUGIN_BAD_DASH disabled)
endif()

if("dc1394" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BAD_DC1394 enabled)
else()
    set(PLUGIN_BAD_DC1394 disabled)
endif()

if("dtls" IN_LIST FEATURES)
    set(PLUGIN_BAD_DTLS enabled)
else()
    set(PLUGIN_BAD_DTLS disabled)
endif()

if("gpl" IN_LIST FEATURES AND "faad" IN_LIST FEATURES)
    set(PLUGIN_BAD_FAAD enabled)
else()
    set(PLUGIN_BAD_FAAD disabled)
endif()

if("fdkaac" IN_LIST FEATURES)
    set(PLUGIN_BAD_FDKAAC enabled)
else()
    set(PLUGIN_BAD_FDKAAC disabled)
endif()

# Plugin requires unistd.h header, which doesn't exist on Windows
if("fluidsynth" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BAD_FLUIDSYNTH enabled)
else()
    set(PLUGIN_BAD_FLUIDSYNTH disabled)
endif()

if("libde265" IN_LIST FEATURES)
    set(PLUGIN_BAD_LIBDE265 enabled)
else()
    set(PLUGIN_BAD_LIBDE265 disabled)
endif()

if("microdns" IN_LIST FEATURES)
    set(PLUGIN_BAD_MICRODNS enabled)
else()
    set(PLUGIN_BAD_MICRODNS disabled)
endif()

if("modplug" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_UWP)
    set(PLUGIN_BAD_MODPLUG enabled)
else()
    set(PLUGIN_BAD_MODPLUG disabled)
endif()

if("openal" IN_LIST FEATURES)
    set(PLUGIN_BAD_OPENAL enabled)
else()
    set(PLUGIN_BAD_OPENAL disabled)
endif()

if("openh264" IN_LIST FEATURES)
    set(PLUGIN_BAD_OPENH264 enabled)
else()
    set(PLUGIN_BAD_OPENH264 disabled)
endif()

if("openjpeg" IN_LIST FEATURES)
    set(PLUGIN_BAD_OPENJPEG enabled)
else()
    set(PLUGIN_BAD_OPENJPEG disabled)
endif()

if("openmpt" IN_LIST FEATURES)
    set(PLUGIN_BAD_OPENMPT enabled)
else()
    set(PLUGIN_BAD_OPENMPT disabled)
endif()

if("opus-bad" IN_LIST FEATURES)
    set(PLUGIN_BAD_OPUS enabled)
else()
    set(PLUGIN_BAD_OPUS disabled)
endif()

if("smoothstreaming" IN_LIST FEATURES)
    set(PLUGIN_BAD_SMOOTHSTREAMING enabled)
else()
    set(PLUGIN_BAD_SMOOTHSTREAMING disabled)
endif()

if("sndfile" IN_LIST FEATURES)
    set(PLUGIN_BAD_SNDFILE enabled)
else()
    set(PLUGIN_BAD_SNDFILE disabled)
endif()

if("soundtouch" IN_LIST FEATURES)
    set(PLUGIN_BAD_SOUNDTOUCH enabled)
else()
    set(PLUGIN_BAD_SOUNDTOUCH disabled)
endif()

if("srt" IN_LIST FEATURES)
    set(PLUGIN_BAD_SRT enabled)
else()
    set(PLUGIN_BAD_SRT disabled)
endif()

if("srtp" IN_LIST FEATURES)
    set(PLUGIN_BAD_SRTP enabled)
else()
    set(PLUGIN_BAD_SRTP disabled)
endif()

if("webp" IN_LIST FEATURES)
    set(PLUGIN_BAD_WEBP enabled)
else()
    set(PLUGIN_BAD_WEBP disabled)
endif()

if("webrtc" IN_LIST FEATURES)
    set(PLUGIN_BAD_WEBRTC enabled)
else()
    set(PLUGIN_BAD_WEBRTC disabled)
endif()

if("wildmidi" IN_LIST FEATURES)
    set(PLUGIN_BAD_WILDMIDI enabled)
else()
    set(PLUGIN_BAD_WILDMIDI disabled)
endif()

if("x11-bad" IN_LIST FEATURES)
    set(PLUGIN_BAD_X11 enabled)
else()
    set(PLUGIN_BAD_X11 disabled)
endif()

if("gpl" IN_LIST FEATURES AND "x265" IN_LIST FEATURES)
    set(PLUGIN_BAD_X265 enabled)
else()
    set(PLUGIN_BAD_X265 disabled)
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
        # General options
        -Dpython=disabled
        -Dlibav=disabled
        -Dlibnice=disabled
        -Ddevtools=disabled
        -Dges=disabled
        -Drtsp_server=disabled
        -Domx=disabled
        -Dvaapi=disabled
        -Dsharp=disabled
        -Drs=disabled
        -Dgst-examples=disabled
        -Dtls=disabled
        -Dqt5=disabled
        -Dgpl=${LICENSE_GPL}
        # Common options
        -Dtests=disabled
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dnls=${NLS}
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
        # gst-plugins-base
        -Dbase=${PLUGIN_BASE_SUPPORT}
        -Dgst-plugins-base:gl_winsys=${PLUGIN_BASE_WINDOW_SYSTEM}
        -Dgst-plugins-base:gl_platform=${PLUGIN_BASE_GL_PLATFORM}
        -Dgst-plugins-base:gl-graphene=${GL_GRAPHENE}
        -Dgst-plugins-base:alsa=${PLUGIN_BASE_ALSA}
        -Dgst-plugins-base:cdparanoia=disabled
        -Dgst-plugins-base:libvisual=disabled
        -Dgst-plugins-base:ogg=${PLUGIN_BASE_OGG}
        -Dgst-plugins-base:opus=${PLUGIN_BASE_OPUS}
        -Dgst-plugins-base:pango=${PLUGIN_BASE_PANGO}
        -Dgst-plugins-base:theora=disabled
        -Dgst-plugins-base:tremor=disabled
        -Dgst-plugins-base:vorbis=${PLUGIN_BASE_VORBIS}
        -Dgst-plugins-base:x11=${PLUGIN_BASE_X11}
        -Dgst-plugins-base:xshm=${PLUGIN_BASE_X11}
        -Dgst-plugins-base:xvideo=disabled
        # gst-plugins-good
        -Dgood=${PLUGIN_GOOD_SUPPORT}
        -Dgst-plugins-good:aalib=disabled
        -Dgst-plugins-good:bz2=disabled
        -Dgst-plugins-good:directsound=auto
        -Dgst-plugins-good:dv=disabled
        -Dgst-plugins-good:dv1394=disabled
        -Dgst-plugins-good:flac=${PLUGIN_GOOD_FLAC}
        -Dgst-plugins-good:gdk-pixbuf=${PLUGIN_GOOD_GDK_PIXBUF}
        -Dgst-plugins-good:gtk3=disabled # GTK version 3 only
        -Dgst-plugins-good:jack=disabled
        -Dgst-plugins-good:jpeg=${PLUGIN_GOOD_JPEG}
        -Dgst-plugins-good:lame=disabled
        -Dgst-plugins-good:libcaca=disabled
        -Dgst-plugins-good:mpg123=${PLUGIN_GOOD_MPG123}
        -Dgst-plugins-good:oss=disabled
        -Dgst-plugins-good:oss4=disabled
        -Dgst-plugins-good:osxaudio=auto
        -Dgst-plugins-good:osxvideo=auto
        -Dgst-plugins-good:png=${PLUGIN_GOOD_PNG}
        -Dgst-plugins-good:pulse=auto
        -Dgst-plugins-good:qt5=disabled
        -Dgst-plugins-good:shout2=disabled
        -Dgst-plugins-good:soup=disabled
        -Dgst-plugins-good:speex=${PLUGIN_GOOD_SPEEX}
        -Dgst-plugins-good:taglib=${PLUGIN_GOOD_TAGLIB}
        -Dgst-plugins-good:twolame=disabled
        -Dgst-plugins-good:vpx=${PLUGIN_GOOD_VPX}
        -Dgst-plugins-good:waveform=auto
        -Dgst-plugins-good:wavpack=disabled # Error during plugin build
        # gst-plugins-ugly
        -Dugly=${PLUGIN_UGLY_SUPPORT}
        -Dgst-plugins-ugly:a52dec=disabled
        -Dgst-plugins-ugly:amrnb=disabled
        -Dgst-plugins-ugly:amrwbdec=disabled
        -Dgst-plugins-ugly:cdio=disabled
        -Dgst-plugins-ugly:dvdread=disabled
        -Dgst-plugins-ugly:mpeg2dec=disabled # libmpeg2 not found
        -Dgst-plugins-ugly:sidplay=disabled
        -Dgst-plugins-ugly:x264=${PLUGIN_UGLY_X264}
        # gst-plugins-bad
        -Dbad=${PLUGIN_BAD_SUPPORT}
        -Dgst-plugins-bad:aes=${PLUGIN_BAD_AES}
        -Dgst-plugins-bad:aom=disabled # Error during plugin build
        -Dgst-plugins-bad:avtp=disabled
        -Dgst-plugins-bad:androidmedia=auto
        -Dgst-plugins-bad:applemedia=auto
        -Dgst-plugins-bad:asio=${PLUGIN_BAD_ASIO}
        -Dgst-plugins-bad:asio-sdk-path=${PLUGIN_BAD_ASIO_SDK_PATH}
        -Dgst-plugins-bad:assrender=${PLUGIN_BAD_ASSRENDER}
        -Dgst-plugins-bad:bluez=disabled
        -Dgst-plugins-bad:bs2b=disabled
        -Dgst-plugins-bad:bz2=disabled # Error during plugin configuration
        -Dgst-plugins-bad:chromaprint=${PLUGIN_BAD_CHROMAPRINT}
        -Dgst-plugins-bad:closedcaption=${PLUGIN_BAD_CLOSEDCAPTION}
        -Dgst-plugins-bad:colormanagement=${PLUGIN_BAD_COLORMANAGEMENT}
        -Dgst-plugins-bad:curl=disabled # Error during plugin build
        -Dgst-plugins-bad:curl-ssh2=disabled
        -Dgst-plugins-bad:d3dvideosink=auto
        -Dgst-plugins-bad:d3d11=auto
        -Dgst-plugins-bad:dash=${PLUGIN_BAD_DASH}
        -Dgst-plugins-bad:dc1394=${PLUGIN_BAD_DC1394}
        -Dgst-plugins-bad:decklink=disabled
        -Dgst-plugins-bad:directfb=disabled
        -Dgst-plugins-bad:directsound=auto
        -Dgst-plugins-bad:dtls=${PLUGIN_BAD_DTLS}
        -Dgst-plugins-bad:dts=disabled
        -Dgst-plugins-bad:dvb=auto
        -Dgst-plugins-bad:faac=disabled
        -Dgst-plugins-bad:faad=${PLUGIN_BAD_FAAD}
        -Dgst-plugins-bad:fbdev=auto
        -Dgst-plugins-bad:fdkaac=${PLUGIN_BAD_FDKAAC}
        -Dgst-plugins-bad:flite=disabled
        -Dgst-plugins-bad:fluidsynth=${PLUGIN_BAD_FLUIDSYNTH}
        -Dgst-plugins-bad:gl=auto
        -Dgst-plugins-bad:gme=disabled
        -Dgst-plugins-bad:gs=disabled # Error during plugin configuration (abseil pkg-config file missing)
        -Dgst-plugins-bad:gsm=disabled
        -Dgst-plugins-bad:ipcpipeline=auto
        -Dgst-plugins-bad:iqa=disabled
        -Dgst-plugins-bad:kate=disabled
        -Dgst-plugins-bad:kms=disabled
        -Dgst-plugins-bad:ladspa=disabled
        -Dgst-plugins-bad:ldac=disabled
        -Dgst-plugins-bad:libde265=${PLUGIN_BAD_LIBDE265}
        -Dgst-plugins-bad:lv2=disabled # Error during plugin configuration (lilv pkg-config file missing)
        -Dgst-plugins-bad:mediafoundation=auto
        -Dgst-plugins-bad:microdns=${PLUGIN_BAD_MICRODNS}
        -Dgst-plugins-bad:modplug=${PLUGIN_BAD_MODPLUG}
        -Dgst-plugins-bad:mpeg2enc=disabled
        -Dgst-plugins-bad:mplex=disabled
        -Dgst-plugins-bad:msdk=disabled
        -Dgst-plugins-bad:musepack=disabled
        -Dgst-plugins-bad:neon=disabled
        -Dgst-plugins-bad:nvcodec=disabled
        -Dgst-plugins-bad:onnx=disabled # libonnxruntime not found
        -Dgst-plugins-bad:openal=${PLUGIN_BAD_OPENAL}
        -Dgst-plugins-bad:openaptx=disabled
        -Dgst-plugins-bad:opencv=disabled # opencv not found
        -Dgst-plugins-bad:openexr=disabled # OpenEXR::IlmImf target not found
        -Dgst-plugins-bad:openh264=${PLUGIN_BAD_OPENH264}
        -Dgst-plugins-bad:openjpeg=${PLUGIN_BAD_OPENJPEG}
        -Dgst-plugins-bad:openmpt=${PLUGIN_BAD_OPENMPT}
        -Dgst-plugins-bad:openni2=disabled # libopenni2 not found
        -Dgst-plugins-bad:opensles=disabled
        -Dgst-plugins-bad:opus=${PLUGIN_BAD_OPUS}
        -Dgst-plugins-bad:qroverlay=disabled
        -Dgst-plugins-bad:resindvd=disabled
        -Dgst-plugins-bad:rsvg=disabled # librsvg-2.0 not found
        -Dgst-plugins-bad:rtmp=disabled # librtmp not found
        -Dgst-plugins-bad:sbc=disabled
        -Dgst-plugins-bad:sctp=auto
        -Dgst-plugins-bad:shm=disabled
        -Dgst-plugins-bad:smoothstreaming=${PLUGIN_BAD_SMOOTHSTREAMING}
        -Dgst-plugins-bad:sndfile=${PLUGIN_BAD_SNDFILE}
        -Dgst-plugins-bad:soundtouch=${PLUGIN_BAD_SOUNDTOUCH}
        -Dgst-plugins-bad:spandsp=disabled
        -Dgst-plugins-bad:srt=${PLUGIN_BAD_SRT}
        -Dgst-plugins-bad:srtp=${PLUGIN_BAD_SRTP}
        -Dgst-plugins-bad:svthevcenc=disabled
        -Dgst-plugins-bad:teletext=disabled
        -Dgst-plugins-bad:tinyalsa=disabled
        -Dgst-plugins-bad:transcode=disabled
        -Dgst-plugins-bad:ttml=disabled
        -Dgst-plugins-bad:uvch264=disabled
        -Dgst-plugins-bad:va=disabled
        -Dgst-plugins-bad:voaacenc=disabled
        -Dgst-plugins-bad:voamrwbenc=disabled
        -Dgst-plugins-bad:vulkan=auto
        -Dgst-plugins-bad:wasapi=auto
        -Dgst-plugins-bad:wasapi2=auto
        -Dgst-plugins-bad:wayland=auto
        -Dgst-plugins-bad:webp=${PLUGIN_BAD_WEBP}
        -Dgst-plugins-bad:webrtc=${PLUGIN_BAD_WEBRTC}
        -Dgst-plugins-bad:wildmidi=${PLUGIN_BAD_WILDMIDI}
        -Dgst-plugins-bad:winks=disabled
        -Dgst-plugins-bad:winscreencap=auto
        -Dgst-plugins-bad:x11=${PLUGIN_BAD_X11}
        -Dgst-plugins-bad:x265=${PLUGIN_BAD_X265}
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
)

vcpkg_install_meson()

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KHR"
                    "${CURRENT_PACKAGES_DIR}/include/GL"
)

if(NOT VCPKG_TARGET_IS_LINUX)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h"
                "${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h"
    )
endif()

list(APPEND GST_BIN_TOOLS
    gst-inspect-1.0
    gst-launch-1.0
    gst-stats-1.0
    gst-typefind-1.0
)
list(APPEND GST_LIBEXEC_TOOLS
    gst-plugin-scanner
)

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

vcpkg_copy_tools(
    TOOL_NAMES ${GST_BIN_TOOLS}
    AUTO_CLEAN
)

vcpkg_copy_tools(
    TOOL_NAMES ${GST_LIBEXEC_TOOLS}
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/libexec/gstreamer-1.0"
    AUTO_CLEAN
)

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

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(NOT VCPKG_BUILD_TYPE)
        file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.dll"
                           "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb"
        )
        file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.dll"
                       "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
