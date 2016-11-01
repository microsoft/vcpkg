include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libjpeg-turbo-1.4.90)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/1.4.90.zip"
    FILENAME "libjpeg-turbo-1.4.90.zip"
    SHA512 43c3d26c70a7356bb0832276fe82eead040c3f4aa17df118f91a38615bfacfdfb25fab41965f9ca2b69d18e0b937a1bb753e93fa2c114e01d5174fc1100010b4
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/add-options-for-exes-docs-headers.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "${NASM_EXE_PATH};$ENV{PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_STATIC OFF)
    set(NOT_BUILD_STATIC ON)
else()
    set(BUILD_STATIC ON)
    set(NOT_BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_STATIC=${BUILD_STATIC}
        -DENABLE_SHARED=${NOT_BUILD_STATIC}
        -DWITH_CRT_DLL=ON
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
    # OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY
    ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/copyright)
vcpkg_copy_pdbs()
