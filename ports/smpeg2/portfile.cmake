
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/smpeg2-2.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/smpeg/release/smpeg2-2.0.0.tar.gz"
    FILENAME "smpeg2-2.0.0.tar.gz"
    SHA512 80a779d01e7aa76778ef6ceea8041537db9e4b354df413214c4413c875cb98551891cef98fa0f057cc6a3222e4983da9ae65b86bdad2f87f9e2a6751837e2baf)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
        ${CMAKE_CURRENT_LIST_DIR}/correct-sdl-headers-dir.patch)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSMPEG_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/smpeg2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/smpeg2/COPYING ${CURRENT_PACKAGES_DIR}/share/smpeg2/copyright)
