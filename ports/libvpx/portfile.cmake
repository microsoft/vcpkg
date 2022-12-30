if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

set(LIBVPX_VERSION 1.12.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libvpx
    REF v${LIBVPX_VERSION}
    SHA512 dc059bc3102b75524ae29989372334b3e0f2acf1520e5a4daa4073831bb55949d82897c498fb9d2d38b59f1a66bb0ad24407d0d086b1e3a8394a4933f04f2ed0
    HEAD_REF master
    PATCHES
        0002-Fix-nasm-debug-format-flag.patch
        0003-add-uwp-v142-and-v143-support.patch
        0004-remove-library-suffixes.patch
        allow-unknown-options.patch
)

set(OPTIONS)
if("realtime" IN_LIST FEATURES)
    list(APPEND OPTIONS "--enable-realtime-only")
endif()

if("highbitdepth" IN_LIST FEATURES)
    list(APPEND OPTIONS "--enable-vp9-highbitdepth")
endif()


if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore AND (VCPKG_PLATFORM_TOOLSET STREQUAL v142 OR VCPKG_PLATFORM_TOOLSET STREQUAL v143))
        set(LIBVPX_TARGET_OS "uwp")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
        set(LIBVPX_TARGET_OS "win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(LIBVPX_TARGET_OS "win64")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(LIBVPX_TARGET_ARCH "x86-${LIBVPX_TARGET_OS}")
        set(LIBVPX_ARCH_DIR "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LIBVPX_TARGET_ARCH "x86_64-${LIBVPX_TARGET_OS}")
        set(LIBVPX_ARCH_DIR "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(LIBVPX_TARGET_ARCH "arm64-${LIBVPX_TARGET_OS}")
        set(LIBVPX_ARCH_DIR "ARM64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
        set(LIBVPX_TARGET_ARCH "armv7-${LIBVPX_TARGET_OS}")
        set(LIBVPX_ARCH_DIR "ARM")
    endif()

    if(VCPKG_PLATFORM_TOOLSET STREQUAL v143)
        set(LIBVPX_TARGET_VS "vs17")
    elseif(VCPKG_PLATFORM_TOOLSET STREQUAL v142)
        set(LIBVPX_TARGET_VS "vs16")
    else()
        set(LIBVPX_TARGET_VS "vs15")
    endif()
    set(LIBVPX_TARGET "${LIBVPX_TARGET_ARCH}-${LIBVPX_TARGET_VS}")
else()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(LIBVPX_TARGET_ARCH "x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LIBVPX_TARGET_ARCH "x86_64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(LIBVPX_TARGET_ARCH "arm64")
    else()
        message(FATAL_ERROR "libvpx does not support architecture ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

	if(VCPKG_TARGET_IS_MINGW)
		if(LIBVPX_TARGET_ARCH STREQUAL "x86")
			set(LIBVPX_TARGET "x86-win32-gcc")
		else()
			set(LIBVPX_TARGET "x86_64-win64-gcc")
		endif()
	elseif(VCPKG_TARGET_IS_LINUX)
        set(LIBVPX_TARGET "${LIBVPX_TARGET_ARCH}-linux-gcc")
    elseif(VCPKG_TARGET_IS_OSX)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(LIBVPX_TARGET "arm64-darwin20-gcc")
        else()
            set(LIBVPX_TARGET "${LIBVPX_TARGET_ARCH}-darwin17-gcc") # enable latest CPU instructions for best performance and less CPU usage on MacOS
        endif()
    else()
        set(LIBVPX_TARGET "generic-gnu") # use default target
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_VERBOSE_FLAGS
    NO_ADDITIONAL_PATHS
    BUILD_TRIPLET --target=${LIBVPX_TARGET}
    OPTIONS
        ${OPTIONS}
        --disable-examples
        --disable-tools
        --disable-docs
        --disable-unit-tests
        --enable-pic
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
