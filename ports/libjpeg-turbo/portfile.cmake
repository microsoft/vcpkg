include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libjpeg-turbo-1.4.90)

vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/1.4.90.zip"
    FILENAME "libjpeg-turbo-1.4.90.zip"
    MD5 dcd49a7100e41870faae988f608471af
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/add-options-for-exes-docs-headers.patch"
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "${NASM_EXE_PATH};$ENV{PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_STATIC=OFF
        -DWITH_CRT_DLL=ON
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
    # OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(COPY
    ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libjpeg-turbo/copyright)
vcpkg_copy_pdbs()
