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

set(OPTIONS "")
if("realtime" IN_LIST FEATURES)
    list(APPEND OPTIONS "--enable-realtime-only")
endif()

if("highbitdepth" IN_LIST FEATURES)
    list(APPEND OPTIONS "--enable-vp9-highbitdepth")
endif()

vcpkg_find_acquire_program(PERL)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
    set(ENV{PATH} "${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
endif()

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    if(VCPKG_CRT_LINKAGE STREQUAL static)
        set(LIBVPX_CRT_LINKAGE --enable-static-msvcrt)
        set(LIBVPX_CRT_SUFFIX mt)
    else()
        set(LIBVPX_CRT_SUFFIX md)
    endif()

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

    message(STATUS "Generating makefile")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    
    vcpkg_execute_required_process(
        COMMAND
            ${BASH} --noprofile --norc
            "${SOURCE_PATH}/configure"
            --target=${LIBVPX_TARGET_ARCH}-${LIBVPX_TARGET_VS}
            ${LIBVPX_CRT_LINKAGE}
            ${OPTIONS}
            --as=nasm
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}"
        LOGNAME configure-${TARGET_TRIPLET})

    message(STATUS "Generating MSBuild projects")
    vcpkg_install_make()
    message(FATAL_ERROR "abort to get logs")

    # note: pdb file names are hardcoded in the lib file, cannot rename
    set(LIBVPX_OUTPUT_PREFIX "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Release/vpx.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        if (EXISTS "${LIBVPX_OUTPUT_PREFIX}/Release/vpx.pdb")
            file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Release/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        else()
            file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Release/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Debug/vpx.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        if (EXISTS "${LIBVPX_OUTPUT_PREFIX}/Debug/vpx.pdb")
            file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Debug/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        else()
            file(INSTALL "${LIBVPX_OUTPUT_PREFIX}/Debug/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()

    if (VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(LIBVPX_INCLUDE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vpx-vp8-vp9-nopost-nodocs-${LIBVPX_TARGET_ARCH}${LIBVPX_CRT_SUFFIX}-${LIBVPX_TARGET_VS}-v${LIBVPX_VERSION}/include/vpx")
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
        set(LIBVPX_INCLUDE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vpx-vp8-vp9-nopost-nomt-nodocs-${LIBVPX_TARGET_ARCH}${LIBVPX_CRT_SUFFIX}-${LIBVPX_TARGET_VS}-v${LIBVPX_VERSION}/include/vpx")
    else()
        set(LIBVPX_INCLUDE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vpx-vp8-vp9-nodocs-${LIBVPX_TARGET_ARCH}${LIBVPX_CRT_SUFFIX}-${LIBVPX_TARGET_VS}-v${LIBVPX_VERSION}/include/vpx")
    endif()
    file(
        INSTALL
            "${LIBVPX_INCLUDE_DIR}"
        DESTINATION
            "${CURRENT_PACKAGES_DIR}/include"
        RENAME
            "vpx")
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(LIBVPX_PREFIX "${CURRENT_INSTALLED_DIR}")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/vpx.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/vpx.pc" @ONLY)
    endif()

    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(LIBVPX_PREFIX "${CURRENT_INSTALLED_DIR}/debug")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/vpx.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vpx.pc" @ONLY)
    endif()
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
        --as=nasm
)

vcpkg_install_make()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
