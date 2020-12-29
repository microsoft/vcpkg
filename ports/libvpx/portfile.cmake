vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(LIBVPX_VERSION 1.9.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libvpx
    REF v${LIBVPX_VERSION}
    SHA512 8d544552b35000ea5712aec220b78bb5f7dc210704b2f609365214cb95a4f5a0e343b362723d829cb4a9ac203b10d5443700ba84b28fd6b2fefbabb40663e298
    HEAD_REF master
)

vcpkg_find_acquire_program(PERL)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

if(CMAKE_HOST_WIN32)
	vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
	set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
	set(ENV{PATH} "${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
else()
	set(BASH /bin/bash)
	set(ENV{PATH} "${MSYS_ROOT}/usr/bin:$ENV{PATH}:${PERL_EXE_PATH}")
endif()

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(PREPEND_TO_PATH OUT_VAR ENV{AS})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

    if(VCPKG_CRT_LINKAGE STREQUAL static)
        set(LIBVPX_CRT_LINKAGE --enable-static-msvcrt)
        set(LIBVPX_CRT_SUFFIX mt)
    else()
        set(LIBVPX_CRT_SUFFIX md)
    endif()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(LIBVPX_TARGET_ARCH "x86-win32")
        set(LIBVPX_ARCH_DIR "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(LIBVPX_TARGET_ARCH "x86_64-win64")
        set(LIBVPX_ARCH_DIR "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
        set(LIBVPX_TARGET_ARCH "arm64-win64")
        set(LIBVPX_ARCH_DIR "ARM64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
        set(LIBVPX_TARGET_ARCH "armv7-win32")
        set(LIBVPX_ARCH_DIR "ARM")
    endif()

    set(LIBVPX_TARGET_VS "vs15")

    message(STATUS "Generating makefile")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
    vcpkg_execute_required_process(
        COMMAND
            ${BASH} --noprofile --norc
            "${SOURCE_PATH}/configure"
            --target=${LIBVPX_TARGET_ARCH}-${LIBVPX_TARGET_VS}
            ${LIBVPX_CRT_LINKAGE}
            --disable-examples
            --disable-tools
            --disable-docs
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}"
        LOGNAME configure-${TARGET_TRIPLET})

    message(STATUS "Generating MSBuild projects")
    vcpkg_execute_required_process(
        COMMAND
            ${BASH} --noprofile --norc -c "make dist"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}"
        LOGNAME generate-${TARGET_TRIPLET})

    vcpkg_build_msbuild(
        PROJECT_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vpx.vcxproj"
        OPTIONS /p:UseEnv=True
    )

    # note: pdb file names are hardcoded in the lib file, cannot rename
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpxmd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        else()
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpxmt.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpxmdd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        else()
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpxmtd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
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
            ${LIBVPX_INCLUDE_DIR}
        DESTINATION
            "${CURRENT_PACKAGES_DIR}/include"
        RENAME
            "vpx")

else()

    set(OPTIONS "--disable-examples --disable-tools --disable-docs --disable-unit-tests")

    set(OPTIONS_DEBUG "--enable-debug-libs --enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug")
    set(OPTIONS_RELEASE "--prefix=${CURRENT_PACKAGES_DIR}")
	
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(OPTIONS "${OPTIONS} --disable-static --enable-shared")
    else()
        set(OPTIONS "${OPTIONS} --enable-static --disable-shared")
    endif()
    
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
        set(LIBVPX_TARGET "${LIBVPX_TARGET_ARCH}-darwin17-gcc") # enable latest CPU instructions for best performance and less CPU usage on MacOS
    else()
        set(LIBVPX_TARGET "generic-gnu") # use default target
    endif()

    message(STATUS "Build info. Target: ${LIBVPX_TARGET}; Options: ${OPTIONS}")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring libvpx for Release")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        vcpkg_execute_required_process(
        COMMAND
            ${BASH} --noprofile --norc
            "${SOURCE_PATH}/configure"
            --target=${LIBVPX_TARGET}
            ${OPTIONS}
            ${OPTIONS_RELEASE}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME configure-${TARGET_TRIPLET}-rel)

        message(STATUS "Building libvpx for Release")
        vcpkg_execute_required_process(
            COMMAND
                ${BASH} --noprofile --norc -c "make -j8"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME build-${TARGET_TRIPLET}-rel
        )

        message(STATUS "Installing libvpx for Release")
        vcpkg_execute_required_process(
            COMMAND
                ${BASH} --noprofile --norc -c "make install"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME install-${TARGET_TRIPLET}-rel
        )
    endif()

    # --- --- ---

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Configuring libvpx for Debug")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        vcpkg_execute_required_process(
        COMMAND
            ${BASH} --noprofile --norc
            "${SOURCE_PATH}/configure"
            --target=${LIBVPX_TARGET}
            ${OPTIONS}
            ${OPTIONS_DEBUG}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME configure-${TARGET_TRIPLET}-dbg)

        message(STATUS "Building libvpx for Debug")
        vcpkg_execute_required_process(
            COMMAND
                ${BASH} --noprofile --norc -c "make -j8"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )

        message(STATUS "Installing libvpx for Debug")
        vcpkg_execute_required_process(
            COMMAND
                ${BASH} --noprofile --norc -c "make install"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME install-${TARGET_TRIPLET}-dbg
        )

        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libvpx_g.a)
    endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(LIBVPX_CONFIG_DEBUG ON)
else()
    set(LIBVPX_CONFIG_DEBUG OFF)
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/unofficial-libvpx-config.cmake.in ${CURRENT_PACKAGES_DIR}/share/unofficial-libvpx/unofficial-libvpx-config.cmake @ONLY)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
