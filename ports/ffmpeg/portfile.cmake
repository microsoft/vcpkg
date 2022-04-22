if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES 0017-Patch-for-ticket-9019-CUDA-Compile-Broken-Using-MSVC.patch)  # https://trac.ffmpeg.org/ticket/9019
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ffmpeg/ffmpeg
    REF n4.4.1
    SHA512 a53e617937f9892c5cfddb00896be9ad8a3e398dc7cf3b6c893b52ff38aff6ff0cbc61a44cd5f93d9a28f775e71ae82996a5e2b699a769c1de8f882aab34c797
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
        0014-avfilter-dependency-fix.patch  # https://ffmpeg.org/pipermail/ffmpeg-devel/2021-February/275819.html
        0015-Fix-xml2-detection.patch
        0016-configure-dnn-needs-avformat.patch  # https://ffmpeg.org/pipermail/ffmpeg-devel/2021-May/279926.html
        ${PATCHES}
        0018-libaom-Dont-use-aom_codec_av1_dx_algo.patch
        0019-libx264-Do-not-explicitly-set-X264_API_IMPORTS.patch
)

if (SOURCE_PATH MATCHES " ")
    message(FATAL_ERROR "Error: ffmpeg will not build with spaces in the path. Please use a directory with no spaces")
endif()


if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    # ffmpeg nasm build gives link error on x86, so fall back to yasm
    vcpkg_find_acquire_program(YASM)
    get_filename_component(YASM_EXE_PATH "${YASM}" DIRECTORY)
    vcpkg_add_to_path("${YASM_EXE_PATH}")
else()
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH "${NASM}" DIRECTORY)
    vcpkg_add_to_path("${NASM_EXE_PATH}")
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

    set(SHELL "${MSYS_ROOT}/usr/bin/bash.exe")
else()
    set(SHELL /bin/sh)
endif()

if(VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND OPTIONS " --target-os=mingw32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND OPTIONS " --target-os=mingw64")
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND OPTIONS " --target-os=win32")
elseif(VCPKG_TARGET_IS_OSX)
    string(APPEND OPTIONS " --target-os=darwin")
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
    string(APPEND OPTIONS " --target-os=android")
else()
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_DETECTED_MSVC)
    set(OPTIONS "--toolchain=msvc ${OPTIONS}")
    # This is required because ffmpeg depends upon optimizations to link correctly
    string(APPEND VCPKG_COMBINED_C_FLAGS_DEBUG " -O2")
    string(REGEX REPLACE "(^| )-RTC1( |$)" " " VCPKG_COMBINED_C_FLAGS_DEBUG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
    string(REGEX REPLACE "(^| )-Od( |$)" " " VCPKG_COMBINED_C_FLAGS_DEBUG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
    string(REGEX REPLACE "(^| )-Ob0( |$)" " " VCPKG_COMBINED_C_FLAGS_DEBUG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
endif()

string(APPEND VCPKG_COMBINED_C_FLAGS_DEBUG " -I \"${CURRENT_INSTALLED_DIR}/include\"")
string(APPEND VCPKG_COMBINED_C_FLAGS_RELEASE " -I \"${CURRENT_INSTALLED_DIR}/include\"")

set(_csc_PROJECT_PATH ffmpeg)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

set(FFMPEG_PKGCONFIG_MODULES libavutil)

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

if (NOT "alsa" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --disable-alsa")
endif()

if("avcodec" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avcodec")
    set(ENABLE_AVCODEC ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libavcodec)
else()
    set(OPTIONS "${OPTIONS} --disable-avcodec")
    set(ENABLE_AVCODEC OFF)
endif()

if("avdevice" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avdevice")
    set(ENABLE_AVDEVICE ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libavdevice)
else()
    set(OPTIONS "${OPTIONS} --disable-avdevice")
    set(ENABLE_AVDEVICE OFF)
endif()

if("avformat" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avformat")
    set(ENABLE_AVFORMAT ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libavformat)
else()
    set(OPTIONS "${OPTIONS} --disable-avformat")
    set(ENABLE_AVFORMAT OFF)
endif()

if("avfilter" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avfilter")
    set(ENABLE_AVFILTER ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libavfilter)
else()
    set(OPTIONS "${OPTIONS} --disable-avfilter")
    set(ENABLE_AVFILTER OFF)
endif()

if("postproc" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-postproc")
    set(ENABLE_POSTPROC ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libpostproc)
else()
    set(OPTIONS "${OPTIONS} --disable-postproc")
    set(ENABLE_POSTPROC OFF)
endif()

if("swresample" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-swresample")
    set(ENABLE_SWRESAMPLE ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libswresample)
else()
    set(OPTIONS "${OPTIONS} --disable-swresample")
    set(ENABLE_SWRESAMPLE OFF)
endif()

if("swscale" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-swscale")
    set(ENABLE_SWSCALE ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libswscale)
else()
    set(OPTIONS "${OPTIONS} --disable-swscale")
    set(ENABLE_SWSCALE OFF)
endif()

set(ENABLE_AVRESAMPLE OFF)
if("avresample" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avresample")
    set(ENABLE_AVRESAMPLE ON)
    list(APPEND FFMPEG_PKGCONFIG_MODULES libavresample)
endif()

set(STATIC_LINKAGE OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(STATIC_LINKAGE ON)
endif()

if("aom" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libaom")
else()
    set(OPTIONS "${OPTIONS} --disable-libaom")
endif()

if("ass" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libass")
else()
    set(OPTIONS "${OPTIONS} --disable-libass")
endif()

if("avisynthplus" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avisynth")
else()
    set(OPTIONS "${OPTIONS} --disable-avisynth")
endif()

if("bzip2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-bzlib")
else()
    set(OPTIONS "${OPTIONS} --disable-bzlib")
endif()

if("dav1d" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libdav1d")
else()
    set(OPTIONS "${OPTIONS} --disable-libdav1d")
endif()

if("fdk-aac" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfdk-aac")
else()
    set(OPTIONS "${OPTIONS} --disable-libfdk-aac")
endif()

if("fontconfig" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfontconfig")
else()
    set(OPTIONS "${OPTIONS} --disable-libfontconfig")
endif()

if("freetype" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfreetype")
else()
    set(OPTIONS "${OPTIONS} --disable-libfreetype")
endif()

if("fribidi" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libfribidi")
else()
    set(OPTIONS "${OPTIONS} --disable-libfribidi")
endif()

if("iconv" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-iconv")
else()
    set(OPTIONS "${OPTIONS} --disable-iconv")
endif()

if("ilbc" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libilbc")
else()
    set(OPTIONS "${OPTIONS} --disable-libilbc")
endif()

if("lzma" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-lzma")
else()
    set(OPTIONS "${OPTIONS} --disable-lzma")
endif()

if("mp3lame" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libmp3lame")
else()
    set(OPTIONS "${OPTIONS} --disable-libmp3lame")
endif()

if("modplug" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libmodplug")
else()
    set(OPTIONS "${OPTIONS} --disable-libmodplug")
endif()

if("nvcodec" IN_LIST FEATURES)
    #Note: the --enable-cuda option does not actually require the cuda sdk or toolset port dependency as ffmpeg uses runtime detection and dynamic loading
    set(OPTIONS "${OPTIONS} --enable-cuda --enable-nvenc --enable-nvdec --enable-cuvid --enable-ffnvcodec")
else()
    set(OPTIONS "${OPTIONS} --disable-cuda --disable-nvenc --disable-nvdec  --disable-cuvid --disable-ffnvcodec")
endif()

if("opencl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-opencl")
else()
    set(OPTIONS "${OPTIONS} --disable-opencl")
endif()

if("opengl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-opengl")
else()
    set(OPTIONS "${OPTIONS} --disable-opengl")
endif()

if("openh264" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopenh264")
else()
    set(OPTIONS "${OPTIONS} --disable-libopenh264")
endif()

if("openjpeg" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopenjpeg")
else()
    set(OPTIONS "${OPTIONS} --disable-libopenjpeg")
endif()

if("openssl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-openssl")
else()
    set(OPTIONS "${OPTIONS} --disable-openssl")
endif()

if("opus" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libopus")
else()
    set(OPTIONS "${OPTIONS} --disable-libopus")
endif()

if("sdl2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-sdl2")
else()
    set(OPTIONS "${OPTIONS} --disable-sdl2")
endif()

if("snappy" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libsnappy")
else()
    set(OPTIONS "${OPTIONS} --disable-libsnappy")
endif()

if("soxr" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libsoxr")
else()
    set(OPTIONS "${OPTIONS} --disable-libsoxr")
endif()

if("speex" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libspeex")
else()
    set(OPTIONS "${OPTIONS} --disable-libspeex")
endif()

if("ssh" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libssh")
else()
    set(OPTIONS "${OPTIONS} --disable-libssh")
endif()

if("tensorflow" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtensorflow")
else()
    set(OPTIONS "${OPTIONS} --disable-libtensorflow")
endif()

if("tesseract" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtesseract")
else()
    set(OPTIONS "${OPTIONS} --disable-libtesseract")
endif()

if("theora" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libtheora")
else()
    set(OPTIONS "${OPTIONS} --disable-libtheora")
endif()

if("vorbis" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libvorbis")
else()
    set(OPTIONS "${OPTIONS} --disable-libvorbis")
endif()

if("vpx" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libvpx")
else()
    set(OPTIONS "${OPTIONS} --disable-libvpx")
endif()

if("webp" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libwebp")
else()
    set(OPTIONS "${OPTIONS} --disable-libwebp")
endif()

if("x264" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libx264")
else()
    set(OPTIONS "${OPTIONS} --disable-libx264")
endif()

if("x265" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libx265")
else()
    set(OPTIONS "${OPTIONS} --disable-libx265")
endif()

if("xml2" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libxml2")
else()
    set(OPTIONS "${OPTIONS} --disable-libxml2")
endif()

if("zlib" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-zlib")
else()
    set(OPTIONS "${OPTIONS} --disable-zlib")
endif()

if (VCPKG_TARGET_IS_OSX)
    set(OPTIONS "${OPTIONS} --disable-vdpau") # disable vdpau in OSX
endif()

set(OPTIONS_CROSS " --enable-cross-compile")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    string(APPEND OPTIONS_CROSS " --arch=x86_64")
else()
    string(APPEND OPTIONS_CROSS " --arch=${VCPKG_TARGET_ARCHITECTURE}")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_find_acquire_program(GASPREPROCESSOR)
        foreach(GAS_PATH ${GASPREPROCESSOR})
            get_filename_component(GAS_ITEM_PATH ${GAS_PATH} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH}${VCPKG_HOST_PATH_SEPARATOR}${GAS_ITEM_PATH}")
        endforeach(GAS_PATH)
    endif()
endif()

if(VCPKG_TARGET_IS_UWP)
    set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
    string(APPEND OPTIONS " --disable-programs")
    string(APPEND OPTIONS " --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00")
    string(APPEND OPTIONS " --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib")
endif()

# Note: --disable-optimizations can't be used due to https://ffmpeg.org/pipermail/libav-user/2013-March/003945.html
set(OPTIONS_DEBUG "--debug")
set(OPTIONS_RELEASE "")

set(OPTIONS "${OPTIONS} ${OPTIONS_CROSS}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPTIONS "${OPTIONS} --disable-static --enable-shared")
endif()

if(VCPKG_TARGET_IS_MINGW)
    set(OPTIONS "${OPTIONS} --extra_cflags=-D_WIN32_WINNT=0x0601")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS "${OPTIONS} --extra-cflags=-DHAVE_UNISTD_H=0")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPTIONS "${OPTIONS} --pkg-config-flags=--static")
endif()

set(ENV_LIB_PATH "$ENV{${LIB_PATH_VAR}}")

get_filename_component(CC_path "${VCPKG_DETECTED_CMAKE_C_COMPILER}" DIRECTORY)
get_filename_component(CC_filename "${VCPKG_DETECTED_CMAKE_C_COMPILER}" NAME)
set(ENV{CC} "${CC_filename}")
if(CC_path)
    vcpkg_add_to_path(PREPEND "${CC_path}")
endif()

message(STATUS "Building Options: ${OPTIONS}")

# Release build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    message(STATUS "Building Release Options: ${OPTIONS_RELEASE}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/lib${VCPKG_HOST_PATH_SEPARATOR}${ENV_LIB_PATH}")
    set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    # We use response files here as the only known way to handle spaces in paths
    set(crsp "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cflags.rsp")
    file(WRITE "${crsp}" "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
    set(ldrsp "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/ldflags.rsp")
    file(WRITE "${ldrsp}" "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}")
    set(ENV{CFLAGS} "@${crsp}")
    # All tools except the msvc arm{,64} assembler accept @... as response file syntax.
    # For that assembler, there is no known way to pass in flags. We must hope that not passing flags will work acceptably.
    if(NOT VCPKG_DETECTED_MSVC OR NOT VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
        set(ENV{ASFLAGS} "@${crsp}")
    endif()
    set(ENV{LDFLAGS} "@${ldrsp}")

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(CONFIGURE_OPTIONS "${OPTIONS} ${OPTIONS_RELEASE}")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}")

    configure_file("${CMAKE_CURRENT_LIST_DIR}/build.sh.in" "${BUILD_DIR}/build.sh" @ONLY)

    vcpkg_execute_required_process(
        COMMAND "${SHELL}" ./build.sh
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME "build-${TARGET_TRIPLET}-rel"
    )
endif()

# Debug build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    message(STATUS "Building Debug Options: ${OPTIONS_DEBUG}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/debug/lib${VCPKG_HOST_PATH_SEPARATOR}${ENV_LIB_PATH}")
    set(ENV{LDFLAGS} "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}")
    set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(crsp "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/cflags.rsp")
    file(WRITE "${crsp}" "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
    set(ldrsp "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/ldflags.rsp")
    file(WRITE "${ldrsp}" "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}")
    set(ENV{CFLAGS} "@${crsp}")
    if(NOT VCPKG_DETECTED_MSVC OR NOT VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
        set(ENV{ASFLAGS} "@${crsp}")
    endif()
    set(ENV{LDFLAGS} "@${ldrsp}")

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(CONFIGURE_OPTIONS "${OPTIONS} ${OPTIONS_DEBUG}")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}/debug")

    configure_file("${CMAKE_CURRENT_LIST_DIR}/build.sh.in" "${BUILD_DIR}/build.sh" @ONLY)

    vcpkg_execute_required_process(
        COMMAND "${SHELL}" ./build.sh
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME "build-${TARGET_TRIPLET}-dbg"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB DEF_FILES "${CURRENT_PACKAGES_DIR}/lib/*.def" "${CURRENT_PACKAGES_DIR}/debug/lib/*.def")

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
                COMMAND lib.exe "/def:${DEF_FILE_NATIVE}" "/out:${OUT_FILE_NATIVE}" ${LIB_MACHINE_ARG}
                WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
                LOGNAME "libconvert-${TARGET_TRIPLET}"
            )
        endforeach()
    endif()

    file(GLOB EXP_FILES "${CURRENT_PACKAGES_DIR}/lib/*.exp" "${CURRENT_PACKAGES_DIR}/debug/lib/*.exp")
    file(GLOB LIB_FILES "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    if(VCPKG_TARGET_IS_MINGW)
        file(GLOB LIB_FILES_2 "${CURRENT_PACKAGES_DIR}/bin/*.lib" "${CURRENT_PACKAGES_DIR}/debug/bin/*.lib")
    endif()
    set(files_to_remove ${EXP_FILES} ${LIB_FILES} ${LIB_FILES_2} ${DEF_FILES})
    if(files_to_remove)
        file(REMOVE ${files_to_remove})
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    set(_dirs "/")
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        list(APPEND _dirs "/debug/")
    endif()
    foreach(_debug IN LISTS _dirs)
        foreach(PKGCONFIG_MODULE IN LISTS FFMPEG_PKGCONFIG_MODULES)
            set(PKGCONFIG_FILE "${CURRENT_PACKAGES_DIR}${_debug}lib/pkgconfig/${PKGCONFIG_MODULE}.pc")
            # remove redundant cygwin style -libpath entries
            execute_process(
                COMMAND "${MSYS_ROOT}/usr/bin/cygpath.exe" -u "${CURRENT_INSTALLED_DIR}"
                OUTPUT_VARIABLE CYG_INSTALLED_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            vcpkg_replace_string("${PKGCONFIG_FILE}" "-libpath:${CYG_INSTALLED_DIR}${_debug}lib/pkgconfig/../../lib " "")
            # transform libdir, includedir, and prefix paths from cygwin style to windows style
            file(READ "${PKGCONFIG_FILE}" PKGCONFIG_CONTENT)
            foreach(PATH_NAME prefix libdir includedir)
                string(REGEX MATCH "${PATH_NAME}=[^\n]*" PATH_VALUE "${PKGCONFIG_CONTENT}")
                string(REPLACE "${PATH_NAME}=" "" PATH_VALUE "${PATH_VALUE}")
                if(NOT PATH_VALUE)
                    message(FATAL_ERROR "failed to find pkgconfig variable ${PATH_NAME}")
                endif()
                execute_process(
                    COMMAND "${MSYS_ROOT}/usr/bin/cygpath.exe" -w "${PATH_VALUE}"
                    OUTPUT_VARIABLE FIXED_PATH
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                )
                file(TO_CMAKE_PATH "${FIXED_PATH}" FIXED_PATH)
                vcpkg_replace_string("${PKGCONFIG_FILE}" "${PATH_NAME}=${PATH_VALUE}" "${PATH_NAME}=${FIXED_PATH}")
            endforeach()
            # list libraries with -l flag (so pkgconf knows they are libraries and not just linker flags)
            foreach(LIBS_ENTRY Libs Libs.private)
                string(REGEX MATCH "${LIBS_ENTRY}: [^\n]*" LIBS_VALUE "${PKGCONFIG_CONTENT}")
                if(NOT LIBS_VALUE)
                    message(FATAL_ERROR "failed to find pkgconfig entry ${LIBS_ENTRY}")
                endif()
                string(REPLACE "${LIBS_ENTRY}: " "" LIBS_VALUE "${LIBS_VALUE}")
                if(LIBS_VALUE)
                    set(LIBS_VALUE_OLD "${LIBS_VALUE}")
                    string(REGEX REPLACE "([^ ]+)[.]lib" "-l\\1" LIBS_VALUE "${LIBS_VALUE}")
                    set(LIBS_VALUE_NEW "${LIBS_VALUE}")
                    vcpkg_replace_string("${PKGCONFIG_FILE}" "${LIBS_ENTRY}: ${LIBS_VALUE_OLD}" "${LIBS_ENTRY}: ${LIBS_VALUE_NEW}")
                endif()
            endforeach()
        endforeach()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()

# Handle dependencies

x_vcpkg_pkgconfig_get_modules(PREFIX FFMPEG_PKGCONFIG MODULES ${FFMPEG_PKGCONFIG_MODULES} LIBS)

function(append_dependencies_from_libs out)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "" "LIBS" "")
    string(REGEX REPLACE "[ ]+" ";" contents "${arg_LIBS}")
    list(FILTER contents EXCLUDE REGEX "^-framework$")
    list(FILTER contents EXCLUDE REGEX "^-L.+")
    list(FILTER contents EXCLUDE REGEX "^-libpath:.+")
    list(TRANSFORM contents REPLACE "^-Wl,-framework," "-l")
    list(FILTER contents EXCLUDE REGEX "^-Wl,.+")
    list(TRANSFORM contents REPLACE "^-l" "")
    list(FILTER contents EXCLUDE REGEX "^avresample$")
    list(FILTER contents EXCLUDE REGEX "^avutil$")
    list(FILTER contents EXCLUDE REGEX "^avcodec$")
    list(FILTER contents EXCLUDE REGEX "^avdevice$")
    list(FILTER contents EXCLUDE REGEX "^avfilter$")
    list(FILTER contents EXCLUDE REGEX "^avformat$")
    list(FILTER contents EXCLUDE REGEX "^postproc$")
    list(FILTER contents EXCLUDE REGEX "^swresample$")
    list(FILTER contents EXCLUDE REGEX "^swscale$")
    if(VCPKG_TARGET_IS_WINDOWS)
        list(TRANSFORM contents TOLOWER)
    endif()
    if(contents)
        list(APPEND "${out}" "${contents}")
        set("${out}" "${${out}}" PARENT_SCOPE)
    endif()
endfunction()

append_dependencies_from_libs(FFMPEG_DEPENDENCIES_RELEASE LIBS "${FFMPEG_PKGCONFIG_LIBS_RELEASE}")
append_dependencies_from_libs(FFMPEG_DEPENDENCIES_DEBUG   LIBS "${FFMPEG_PKGCONFIG_LIBS_DEBUG}")

# must remove duplicates from the front to respect link order so reverse first
list(REVERSE FFMPEG_DEPENDENCIES_RELEASE)
list(REVERSE FFMPEG_DEPENDENCIES_DEBUG)
list(REMOVE_DUPLICATES FFMPEG_DEPENDENCIES_RELEASE)
list(REMOVE_DUPLICATES FFMPEG_DEPENDENCIES_DEBUG)
list(REVERSE FFMPEG_DEPENDENCIES_RELEASE)
list(REVERSE FFMPEG_DEPENDENCIES_DEBUG)

message(STATUS "Dependencies (release): ${FFMPEG_DEPENDENCIES_RELEASE}")
message(STATUS "Dependencies (debug):   ${FFMPEG_DEPENDENCIES_DEBUG}")

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
file(STRINGS "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-out.log" LICENSE_STRING REGEX "License: .*" LIMIT_COUNT 1)
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
    file(WRITE "${SOURCE_PATH}/${LICENSE_FILE}" "${LICENSE_STRING}")
else()
    message(FATAL_ERROR "Failed to identify license (${LICENSE_STRING})")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/FindFFMPEG.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/FindFFMPEG.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/${LICENSE_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
