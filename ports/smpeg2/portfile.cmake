vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/smpeg/release/smpeg2-${VERSION}.tar.gz"
    FILENAME "smpeg2-${VERSION}.tar.gz"
    SHA512 80a779d01e7aa76778ef6ceea8041537db9e4b354df413214c4413c875cb98551891cef98fa0f057cc6a3222e4983da9ae65b86bdad2f87f9e2a6751837e2baf
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES 
        hufftable-uint.patch
        003-fix-double-ptr-to-int-comparison.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSMPEG_SKIP_HEADERS=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_ALSA
        CMAKE_REQUIRE_FIND_PACKAGE_ALSA
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-smpeg2)
file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-smpeg2/unofficial-smpeg2-config.cmake" config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-smpeg2/unofficial-smpeg2-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(SDL2 CONFIG)
${config}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${SOURCE_PATH}/video/video.h" video_terms)
string(REGEX REPLACE "#ifndef .*" "" video_terms "${video_terms}")
file(WRITE "${SOURCE_PATH}/Additional notes" "${video_terms}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/Additional notes")
