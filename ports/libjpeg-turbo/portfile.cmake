include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF 1.5.2
    SHA512 43f0c3e8c87bef4f0010827fd3c245df2467c0a6c714d2984284d3a64f933d06bbffc9fb893c8f3f2cd7f8fce2702cf39074c34e5bf370d90d1ca0d03c803590
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/add-options-for-exes-docs-headers.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(ENABLE_STATIC OFF)
    set(ENABLE_SHARED ON)
else()
    set(ENABLE_STATIC ON)
    set(ENABLE_SHARED OFF)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

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
