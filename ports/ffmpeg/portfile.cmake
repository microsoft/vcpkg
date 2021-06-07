if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES 0017-Patch-for-ticket-9019-CUDA-Compile-Broken-Using-MSVC.patch)  # https://trac.ffmpeg.org/ticket/9019
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ffmpeg/ffmpeg
    REF n4.4
    SHA512 ae7426ca476df9fa9dba52cab06c38e484f835653fb2da57e7c06f5589d887c0854ee17df93a2f57191d498c1264cb1c69312cf0a8214b476800382e2d260c4b
    HEAD_REF master
    PATCHES
        0001-create-lib-libraries.patch
        0003-fix-windowsinclude.patch
        0004-fix-debug-build.patch
        0006-fix-StaticFeatures.patch
        0007-fix-lib-naming.patch
        0009-Fix-fdk-detection.patch
        0010-Fix-x264-detection.patch
        0011-Fix-x265-detection.patch
        0012-Fix-ssl-110-detection.patch
        0013-define-WINVER.patch
        0014-avfilter-dependency-fix.patch  # http://ffmpeg.org/pipermail/ffmpeg-devel/2021-February/275819.html
        0015-Fix-xml2-detection.patch
        0016-configure-dnn-needs-avformat.patch  # http://ffmpeg.org/pipermail/ffmpeg-devel/2021-May/279926.html
        ${PATCHES}
)

if (SOURCE_PATH MATCHES " ")
    message(FATAL_ERROR "Error: ffmpeg will not build with spaces in the path. Please use a directory with no spaces")
endif()


if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    # ffmpeg nasm build gives link error on x86, so fall back to yasm
    vcpkg_find_acquire_program(YASM)
    get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
    vcpkg_add_to_path(${YASM_EXE_PATH})
else()
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(${NASM_EXE_PATH})
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    #We're assuming that if we're building for Windows we're using MSVC
    set(INCLUDE_VAR "INCLUDE")
    set(LIB_PATH_VAR "LIB")
else()
    set(INCLUDE_VAR "CPATH")
    set(LIB_PATH_VAR "LIBRARY_PATH")
endif()

set(OPTIONS "--enable-pic --disable-doc --enable-debug --enable-runtime-cpudetect")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(OPTIONS "${OPTIONS} --disable-asm --disable-x86asm")
endif()
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(OPTIONS "${OPTIONS} --enable-asm --disable-x86asm")
endif()
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(OPTIONS "${OPTIONS} --enable-asm --enable-x86asm")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_acquire_msys(MSYS_ROOT
            DIRECT_PACKAGES
                # Required for "cpp.exe" preprocessor
                "https://repo.msys2.org/msys/x86_64/gcc-9.3.0-1-x86_64.pkg.tar.xz"
                76af0192a092278e6b26814b2d92815a2c519902a3fec056b057faec19623b1770ac928a59a39402db23cfc23b0d7601b7f88b367b27269361748c69d08654b2
                "https://repo.msys2.org/msys/x86_64/isl-0.22.1-1-x86_64.pkg.tar.xz"
                f4db50d00bad0fa0abc6b9ad965b0262d936d437a9faa35308fa79a7ee500a474178120e487b2db2259caf51524320f619e18d92acf4f0b970b5cbe5cc0f63a2
                "https://repo.msys2.org/msys/x86_64/zlib-1.2.11-1-x86_64.pkg.tar.xz"
                b607da40d3388b440f2a09e154f21966cd55ad77e02d47805f78a9dee5de40226225bf0b8335fdfd4b83f25ead3098e9cb974d4f202f28827f8468e30e3b790d
                "https://repo.msys2.org/msys/x86_64/mpc-1.1.0-1-x86_64.pkg.tar.xz"
                7d0715c41c27fdbf91e6dcc73d6b8c02ee62c252e027f0a17fa4bfb974be8a74d8e3a327ef31c2460721902299ef69a7ef3c7fce52c8f02ce1cb47f0b6e073e9
                "https://repo.msys2.org/msys/x86_64/mpfr-4.1.0-1-x86_64.pkg.tar.zst"
                d64fa60e188124591d41fc097d7eb51d7ea4940bac05cdcf5eafde951ed1eaa174468f5ede03e61106e1633e3428964b34c96de76321ed8853b398fbe8c4d072
                "https://repo.msys2.org/msys/x86_64/gmp-6.2.0-1-x86_64.pkg.tar.xz"
                1389a443e775bb255d905665dd577bef7ed71d51a8c24d118097f8119c08c4dfe67505e88ddd1e9a3764dd1d50ed8b84fa34abefa797d257e90586f0cbf54de8
        )
    else()
        vcpkg_acquire_msys(MSYS_ROOT)
    endif()

    set(SHELL ${MSYS_ROOT}/usr/bin/bash.exe)
    if(VCPKG_TARGET_IS_MINGW)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(OPTIONS "--target-os=mingw32 ${OPTIONS}")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(OPTIONS "--target-os=mingw64 ${OPTIONS}")
        endif()
    else()
        set(OPTIONS "--toolchain=msvc ${OPTIONS}")
    endif()
else()
    set(SHELL /bin/sh)
endif()

set(ENV{${INCLUDE_VAR}} "${CURRENT_INSTALLED_DIR}/include${VCPKG_HOST_PATH_SEPARATOR}$ENV{${INCLUDE_VAR}}")

set(_csc_PROJECT_PATH ffmpeg)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

if("nonfree" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-nonfree")
endif()

if("gpl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-gpl")
endif()

if("version3" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-version3")
endif()

if("ffmpeg" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffmpeg")
else()
    set(OPTIONS "${OPTIONS} --disable-ffmpeg")
endif()

if("ffplay" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffplay")
else()
    set(OPTIONS "${OPTIONS} --disable-ffplay")
endif()

if("ffprobe" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffprobe")
else()
    set(OPTIONS "${OPTIONS} --disable-ffprobe")
endif()

if("avcodec" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avcodec")
    set(ENABLE_AVCODEC ON)
else()
    set(OPTIONS "${OPTIONS} --disable-avcodec")
    set(ENABLE_AVCODEC OFF)
endif()

if("avdevice" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avdevice")
    set(ENABLE_AVDEVICE ON)
else()
    set(OPTIONS "${OPTIONS} --disable-avdevice")
    set(ENABLE_AVDEVICE OFF)
endif()

if("avformat" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avformat")
    set(ENABLE_AVFORMAT ON)
else()
    set(OPTIONS "${OPTIONS} --disable-avformat")
    set(ENABLE_AVFORMAT OFF)
endif()

if("avfilter" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avfilter")
    set(ENABLE_AVFILTER ON)
else()
    set(OPTIONS "${OPTIONS} --disable-avfilter")
    set(ENABLE_AVFILTER OFF)
endif()

if("postproc" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-postproc")
    set(ENABLE_POSTPROC ON)
else()
    set(OPTIONS "${OPTIONS} --disable-postproc")
    set(ENABLE_POSTPROC OFF)
endif()

if("swresample" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-swresample")
    set(ENABLE_SWRESAMPLE ON)
else()
    set(OPTIONS "${OPTIONS} --disable-swresample")
    set(ENABLE_SWRESAMPLE OFF)
endif()

if("swscale" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-swscale")
    set(ENABLE_SWSCALE ON)
else()
    set(OPTIONS "${OPTIONS} --disable-swscale")
    set(ENABLE_SWSCALE OFF)
endif()

set(ENABLE_AVRESAMPLE OFF)
if("avresample" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avresample")
    set(ENABLE_AVRESAMPLE ON)
endif()

set(STATIC_LINKAGE OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(STATIC_LINKAGE ON)
endif()

set(ENABLE_ASS OFF)
if("ass" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libass")
    set(ENABLE_ASS ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libass")
endif()

if("avisynthplus" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avisynth")
else()
    set(OPTIONS "${OPTIONS} --disable-avisynth")
endif()

set(ENABLE_BZIP2 OFF)
if("bzip2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-bzlib")
    set(ENABLE_BZIP2 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-bzlib")
endif()

set(ENABLE_DAV1D OFF)
if("dav1d" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libdav1d")
    set(ENABLE_DAV1D ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libdav1d")
endif()

set(ENABLE_ICONV OFF)
if("iconv" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-iconv")
    set(ENABLE_ICONV ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-iconv")
endif()

set(ENABLE_ILBC OFF)
if("ilbc" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libilbc")
    set(ENABLE_ILBC ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libilbc")
endif()

set(ENABLE_FDKAAC OFF)
if("fdk-aac" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfdk-aac")
    set(ENABLE_FDKAAC ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libfdk-aac")
endif()

set(ENABLE_FONTCONFIG OFF)
if("fontconfig" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfontconfig")
    set(ENABLE_FONTCONFIG ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libfontconfig")
endif()

set(ENABLE_FREETYPE OFF)
if("freetype" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfreetype")
    set(ENABLE_FREETYPE ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libfreetype")
endif()

set(ENABLE_FRIBIDI OFF)
if("fribidi" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfribidi")
    set(ENABLE_FRIBIDI ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libfribidi")
endif()

set(ENABLE_LZMA OFF)
if("lzma" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-lzma")
    set(ENABLE_LZMA ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-lzma")
endif()

set(ENABLE_LAME OFF)
if("mp3lame" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libmp3lame")
    set(ENABLE_LAME ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libmp3lame")
endif()

set(ENABLE_MODPLUG OFF)
if("modplug" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libmodplug")
    set(ENABLE_MODPLUG ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libmodplug")
endif()

set(ENABLE_NVCODEC OFF)
if("nvcodec" IN_LIST FEATURES)
    #Note: the --enable-cuda option does not actually require the cuda sdk or toolset port dependency as ffmpeg uses runtime detection and dynamic loading
    set(ENABLE_NVCODEC ON)
    set(OPTIONS "${OPTIONS} --enable-cuda --enable-nvenc --enable-nvdec --enable-cuvid --enable-ffnvcodec")
else()
    set(OPTIONS "${OPTIONS} --disable-cuda --disable-nvenc --disable-nvdec  --disable-cuvid --disable-ffnvcodec")
endif()

set(ENABLE_OPENCL OFF)
if("opencl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-opencl")
    set(ENABLE_OPENCL ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-opencl")
endif()

set(ENABLE_OPENGL OFF)
if("opengl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-opengl")
    set(ENABLE_OPENGL ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-opengl")
endif()

set(ENABLE_OPENH264 OFF)
if("openh264" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopenh264")
    set(ENABLE_OPENH264 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libopenh264")
endif()

set(ENABLE_OPENJPEG OFF)
if("openjpeg" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopenjpeg")
    set(ENABLE_OPENJPEG ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libopenjpeg")
endif()

set(ENABLE_OPENSSL OFF)
if("openssl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-openssl")
    set(ENABLE_OPENSSL ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-openssl")
endif()

set(ENABLE_OPUS OFF)
if("opus" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopus")
    set(ENABLE_OPUS ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libopus")
endif()

set(ENABLE_SDL2 OFF)
if("sdl2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-sdl2")
    set(ENABLE_SDL2 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-sdl2")
endif()

set(ENABLE_SNAPPY OFF)
if("snappy" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libsnappy")
    set(ENABLE_SNAPPY ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libsnappy")
endif()

set(ENABLE_SOXR OFF)
if("soxr" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libsoxr")
    set(ENABLE_SOXR ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libsoxr")
endif()

set(ENABLE_SPEEX OFF)
if("speex" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libspeex")
    set(ENABLE_SPEEX ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libspeex")
endif()

set(ENABLE_SSH OFF)
if("ssh" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libssh")
    set(ENABLE_SSH ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libssh")
endif()

set(ENABLE_TENSORFLOW OFF)
if("tensorflow" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtensorflow")
    set(ENABLE_TENSORFLOW ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libtensorflow")
endif()

set(ENABLE_TESSERACT OFF)
if("tesseract" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtesseract")
    set(ENABLE_TESSERACT ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libtesseract")
endif()

set(ENABLE_THEORA OFF)
if("theora" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtheora")
    set(ENABLE_THEORA ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libtheora")
endif()

set(ENABLE_VORBIS OFF)
if("vorbis" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libvorbis")
    set(ENABLE_VORBIS ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libvorbis")
endif()

set(ENABLE_VPX OFF)
if("vpx" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libvpx")
    set(ENABLE_VPX ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libvpx")
endif()

set(ENABLE_WEBP OFF)
if("webp" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libwebp")
    set(ENABLE_WEBP ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libwebp")
endif()

set(ENABLE_X264 OFF)
if("x264" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libx264")
    set(ENABLE_X264 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libx264")
endif()

set(ENABLE_X265 OFF)
if("x265" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libx265")
    set(ENABLE_X265 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libx265")
endif()

set(ENABLE_XML2 OFF)
if("xml2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libxml2")
    set(ENABLE_XML2 ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-libxml2")
endif()

set(ENABLE_ZLIB OFF)
if("zlib" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-zlib")
    set(ENABLE_ZLIB ${STATIC_LINKAGE})
else()
    set(OPTIONS "${OPTIONS} --disable-zlib")
endif()

if (VCPKG_TARGET_IS_OSX)
    set(OPTIONS "${OPTIONS} --disable-vdpau") # disable vdpau in OSX
endif()

set(OPTIONS_CROSS "")

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(OPTIONS_CROSS " --enable-cross-compile --target-os=win32 --arch=${VCPKG_TARGET_ARCHITECTURE}")
        vcpkg_find_acquire_program(GASPREPROCESSOR)
        foreach(GAS_PATH ${GASPREPROCESSOR})
            get_filename_component(GAS_ITEM_PATH ${GAS_PATH} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH}${VCPKG_HOST_PATH_SEPARATOR}${GAS_ITEM_PATH}")
        endforeach(GAS_PATH)
    elseif(VCPKG_TARGET_IS_OSX) # VCPKG_TARGET_ARCHITECTURE = arm64
        set(OPTIONS_CROSS " --enable-cross-compile --target-os=darwin --arch=arm64 --extra-ldflags=-arch --extra-ldflags=arm64 --extra-cflags=-arch --extra-cflags=arm64 --extra-cxxflags=-arch --extra-cxxflags=arm64")
    endif()
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

if(VCPKG_TARGET_IS_UWP)
    set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
    set(OPTIONS "${OPTIONS} --disable-programs")
    set(OPTIONS "${OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00")
    set(OPTIONS_CROSS " --enable-cross-compile --target-os=win32 --arch=${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(OPTIONS_DEBUG "--debug") # Note: --disable-optimizations can't be used due to http://ffmpeg.org/pipermail/libav-user/2013-March/003945.html
set(OPTIONS_RELEASE "")

set(OPTIONS "${OPTIONS} ${OPTIONS_CROSS}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPTIONS "${OPTIONS} --disable-static --enable-shared")
    if (VCPKG_TARGET_IS_UWP)
        set(OPTIONS "${OPTIONS} --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib")
    endif()
endif()

if(VCPKG_TARGET_IS_MINGW)
    set(OPTIONS "${OPTIONS} --extra_cflags=-D_WIN32_WINNT=0x0601")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS "${OPTIONS} --extra-cflags=-DHAVE_UNISTD_H=0")
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(OPTIONS_DEBUG "${OPTIONS_DEBUG} --extra-cflags=-MDd --extra-cxxflags=-MDd")
        set(OPTIONS_RELEASE "${OPTIONS_RELEASE} --extra-cflags=-MD --extra-cxxflags=-MD")
    else()
        set(OPTIONS_DEBUG "${OPTIONS_DEBUG} --extra-cflags=-MTd --extra-cxxflags=-MTd")
        set(OPTIONS_RELEASE "${OPTIONS_RELEASE} --extra-cflags=-MT --extra-cxxflags=-MT")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPTIONS "${OPTIONS} --pkg-config-flags=--static")
endif()

set(ENV_LIB_PATH "$ENV{${LIB_PATH_VAR}}")

message(STATUS "Building Options: ${OPTIONS}")

# Release build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    message(STATUS "Building Release Options: ${OPTIONS_RELEASE}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/lib${VCPKG_HOST_PATH_SEPARATOR}${ENV_LIB_PATH}")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(CONFIGURE_OPTIONS "${OPTIONS} ${OPTIONS_RELEASE}")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}")

    configure_file("${CMAKE_CURRENT_LIST_DIR}/build.sh.in" "${BUILD_DIR}/build.sh" @ONLY)

    vcpkg_execute_required_process(
        COMMAND ${SHELL} ./build.sh
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
endif()

# Debug build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    message(STATUS "Building Debug Options: ${OPTIONS_DEBUG}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/debug/lib${VCPKG_HOST_PATH_SEPARATOR}${ENV_LIB_PATH}")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(CONFIGURE_OPTIONS "${OPTIONS} ${OPTIONS_DEBUG}")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}/debug")

    configure_file("${CMAKE_CURRENT_LIST_DIR}/build.sh.in" "${BUILD_DIR}/build.sh" @ONLY)

    vcpkg_execute_required_process(
        COMMAND ${SHELL} ./build.sh
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB DEF_FILES ${CURRENT_PACKAGES_DIR}/lib/*.def ${CURRENT_PACKAGES_DIR}/debug/lib/*.def)

    if(NOT VCPKG_TARGET_IS_MINGW)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            set(LIB_MACHINE_ARG /machine:ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(LIB_MACHINE_ARG /machine:ARM64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(LIB_MACHINE_ARG /machine:x86)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(LIB_MACHINE_ARG /machine:x64)
        else()
            message(FATAL_ERROR "Unsupported target architecture")
        endif()

        foreach(DEF_FILE ${DEF_FILES})
            get_filename_component(DEF_FILE_DIR "${DEF_FILE}" DIRECTORY)
            get_filename_component(DEF_FILE_NAME "${DEF_FILE}" NAME)
            string(REGEX REPLACE "-[0-9]*\\.def" "${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" OUT_FILE_NAME "${DEF_FILE_NAME}")
            file(TO_NATIVE_PATH "${DEF_FILE}" DEF_FILE_NATIVE)
            file(TO_NATIVE_PATH "${DEF_FILE_DIR}/${OUT_FILE_NAME}" OUT_FILE_NATIVE)
            message(STATUS "Generating ${OUT_FILE_NATIVE}")
            vcpkg_execute_required_process(
                COMMAND lib.exe /def:${DEF_FILE_NATIVE} /out:${OUT_FILE_NATIVE} ${LIB_MACHINE_ARG}
                WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}
                LOGNAME libconvert-${TARGET_TRIPLET}
            )
        endforeach()
    endif()

    file(GLOB EXP_FILES ${CURRENT_PACKAGES_DIR}/lib/*.exp ${CURRENT_PACKAGES_DIR}/debug/lib/*.exp)
    file(GLOB LIB_FILES ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    if(VCPKG_TARGET_IS_MINGW)
        file(GLOB LIB_FILES_2 ${CURRENT_PACKAGES_DIR}/bin/*.lib ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
    endif()
    list(APPEND FILES_TO_REMOVE ${EXP_FILES} ${LIB_FILES} ${LIB_FILES_2} ${DEF_FILES})
    if(FILES_TO_REMOVE)
        file(REMOVE ${FILES_TO_REMOVE})
    endif()
endif()

if("ffmpeg" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ffmpeg AUTO_CLEAN)
endif()
if("ffprobe" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ffprobe AUTO_CLEAN)
endif()
if("ffplay" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ffplay AUTO_CLEAN)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    # Translate cygpath to local path
    set(CYGPATH_CMD "${MSYS_ROOT}/usr/bin/cygpath.exe" -w)

    foreach(PKGCONFIG_PATH "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        file(GLOB PKGCONFIG_FILES "${PKGCONFIG_PATH}/*.pc")
        foreach(PKGCONFIG_FILE IN LISTS PKGCONFIG_FILES)
            file(READ "${PKGCONFIG_FILE}" PKGCONFIG_CONTENT)
            foreach(PATH_NAME prefix libdir includedir)
                string(REGEX MATCH "${PATH_NAME}=[^\n]*\n" PATH_VALUE "${PKGCONFIG_CONTENT}")
                string(REPLACE "${PATH_NAME}=" "" PATH_VALUE "${PATH_VALUE}")
                string(REPLACE "\n" "" PATH_VALUE "${PATH_VALUE}")
                set("${PATH_NAME}_cygpath" "${PATH_VALUE}")
            endforeach()
            execute_process(
                COMMAND ${CYGPATH_CMD} "${prefix_cygpath}"
                OUTPUT_VARIABLE FIXED_PREFIX_PATH
            )
            string(REPLACE "\n" "" FIXED_PREFIX_PATH "${FIXED_PREFIX_PATH}")
            file(TO_CMAKE_PATH "${FIXED_PREFIX_PATH}" FIXED_PREFIX_PATH)
            execute_process(
                COMMAND ${CYGPATH_CMD} "${libdir_cygpath}"
                OUTPUT_VARIABLE FIXED_LIBDIR_PATH
            )
            string(REPLACE "\n" "" FIXED_LIBDIR_PATH ${FIXED_LIBDIR_PATH})
            file(TO_CMAKE_PATH ${FIXED_LIBDIR_PATH} FIXED_LIBDIR_PATH)
            execute_process(
                COMMAND ${CYGPATH_CMD} "${includedir_cygpath}"
                OUTPUT_VARIABLE FIXED_INCLUDE_PATH
            )
            string(REPLACE "\n" "" FIXED_INCLUDE_PATH "${FIXED_INCLUDE_PATH}")
            file(TO_CMAKE_PATH ${FIXED_INCLUDE_PATH} FIXED_INCLUDE_PATH)

            vcpkg_replace_string("${PKGCONFIG_FILE}" "${prefix_cygpath}" "${FIXED_PREFIX_PATH}")
            vcpkg_replace_string("${PKGCONFIG_FILE}" "${libdir_cygpath}" "${FIXED_LIBDIR_PATH}")
            vcpkg_replace_string("${PKGCONFIG_FILE}" "${includedir_cygpath}" "${FIXED_INCLUDE_PATH}")
        endforeach()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()

# Handle version strings

function(extract_regex_from_file out)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "FILE;REGEX" "")
    file(READ "${arg_FILE}" contents)
    if (contents MATCHES "${arg_REGEX}")
        if(NOT CMAKE_MATCH_COUNT EQUAL 1)
            message(FATAL_ERROR "Could not identify match group in regular expression \"${arg_REGEX}\"")
        endif()
    else()
        message(FATAL_ERROR "Could not find line matching \"${arg_REGEX}\" in file \"${arg_FILE}\"")
    endif()
    set("${out}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()

function(extract_version_from_component out)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "COMPONENT" "")
    string(TOLOWER "${arg_COMPONENT}" component_lower)
    string(TOUPPER "${arg_COMPONENT}" component_upper)
    extract_regex_from_file(major_version
        FILE "${SOURCE_PATH}/${component_lower}/version.h"
        REGEX "#define ${component_upper}_VERSION_MAJOR[ ]+([0-9]+)"
    )
    extract_regex_from_file(minor_version
        FILE "${SOURCE_PATH}/${component_lower}/version.h"
        REGEX "#define ${component_upper}_VERSION_MINOR[ ]+([0-9]+)"
    )
    extract_regex_from_file(micro_version
        FILE "${SOURCE_PATH}/${component_lower}/version.h"
        REGEX "#define ${component_upper}_VERSION_MICRO[ ]+([0-9]+)"
    )
    set("${out}" "${major_version}.${minor_version}.${micro_version}" PARENT_SCOPE)
endfunction()

extract_regex_from_file(FFMPEG_VERSION
    FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libavutil/ffversion.h"
    REGEX "#define FFMPEG_VERSION[ ]+\"(.+)\""
)

extract_version_from_component(LIBAVUTIL_VERSION
    COMPONENT libavutil)
extract_version_from_component(LIBAVCODEC_VERSION
    COMPONENT libavcodec)
extract_version_from_component(LIBAVDEVICE_VERSION
    COMPONENT libavdevice)
extract_version_from_component(LIBAVFILTER_VERSION
    COMPONENT libavfilter)
extract_version_from_component( LIBAVFORMAT_VERSION
    COMPONENT libavformat)
extract_version_from_component(LIBAVRESAMPLE_VERSION
    COMPONENT libavresample)
extract_version_from_component(LIBSWRESAMPLE_VERSION
    COMPONENT libswresample)
extract_version_from_component(LIBSWSCALE_VERSION
    COMPONENT libswscale)

# Handle copyright
file(STRINGS ${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-out.log LICENSE_STRING REGEX "License: .*" LIMIT_COUNT 1)
if(LICENSE_STRING STREQUAL "License: LGPL version 2.1 or later")
    set(LICENSE_FILE "COPYING.LGPLv2.1")
elseif(LICENSE_STRING STREQUAL "License: LGPL version 3 or later")
    set(LICENSE_FILE "COPYING.LGPLv3")
elseif(LICENSE_STRING STREQUAL "License: GPL version 2 or later")
    set(LICENSE_FILE "COPYING.GPLv2")
elseif(LICENSE_STRING STREQUAL "License: GPL version 3 or later")
    set(LICENSE_FILE "COPYING.GPLv3")
elseif(LICENSE_STRING STREQUAL "License: nonfree and unredistributable")
    set(LICENSE_FILE "COPYING.NONFREE")
    file(WRITE ${SOURCE_PATH}/${LICENSE_FILE} ${LICENSE_STRING})
else()
    message(FATAL_ERROR "Failed to identify license (${LICENSE_STRING})")
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/FindFFMPEG.cmake.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/FindFFMPEG.cmake @ONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/${LICENSE_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
