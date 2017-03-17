include(vcpkg_common_functions)

set(LIBJPEGTURBO_VERSION 1.5.1)
set(LIBJPEGTURBO_HASH "7b89f3c707daa98b0ed19ec417aab5273a1248ce7f98722a671ea80558a8eb0e73b136ce7be7c059f9f42262e682743abcab64e325f82cd4bd1531e0a4035209")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libjpeg-turbo-${LIBJPEGTURBO_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${LIBJPEGTURBO_VERSION}.zip"
    FILENAME "libjpeg-turbo-${LIBJPEGTURBO_VERSION}.zip"
    SHA512 ${LIBJPEGTURBO_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/add-options-for-exes-docs-headers.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_STATIC OFF)
    set(NOT_BUILD_STATIC ON)
else()
    set(BUILD_STATIC ON)
    set(NOT_BUILD_STATIC OFF)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${BUILD_STATIC}
        -DENABLE_SHARED=${NOT_BUILD_STATIC}
        -DWITH_CRT_DLL=ON
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

# Rename libraries for static builds
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/jpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/turbojpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg.lib")
endif()

file(COPY
    ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/copyright)
vcpkg_copy_pdbs()
