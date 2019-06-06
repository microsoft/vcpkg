include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(LIBVPX_VERSION 1.7.0)
set(LIBVPX_HASH 8b3b766b550f8d86907628d7ed88035f9a2612aac21542e0fd5ad35b905eb82cbe1be02a1a24afce7a3bcc4766f62611971f72724761996b392136c40a1e7ff0)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libvpx-${LIBVPX_VERSION})

string(REGEX REPLACE "\\\\" "/" SOURCE_PATH_UNIX ${SOURCE_PATH})
string(REGEX REPLACE "\\\\" "/" CURRENT_PACKAGES_DIR_UNIX ${CURRENT_PACKAGES_DIR})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/webmproject/libvpx/archive/v${LIBVPX_VERSION}/libvpx-${LIBVPX_VERSION}.tar.gz"
    FILENAME "libvpx-${LIBVPX_VERSION}.tar.gz"
    SHA512 ${LIBVPX_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(YASM)
vcpkg_find_acquire_program(PERL)
vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

message(STATUS "PERL_EXE_PATH ; ${PERL_EXE_PATH}")
set(ENV{PATH} "${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

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
        "${SOURCE_PATH_UNIX}/configure"
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
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpxmd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpxmdd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "vpxmd.pdb")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "vpxmdd.pdb")
else()
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpxmt.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpxmtd.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Release/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "vpxmt.pdb")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${LIBVPX_ARCH_DIR}/Debug/vpx/vpx.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "vpxmtd.pdb")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
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

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libvpx)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libvpx/LICENSE ${CURRENT_PACKAGES_DIR}/share/libvpx/copyright)
