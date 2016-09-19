include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://downloads.sourceforge.net/project/mpg123/mpg123/1.23.3/mpg123-1.23.3.tar.bz2"
    FILENAME "mpg123-1.23.3.tar.bz2"
    MD5 84e838650c4c593f4e66d1256e0468db
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "${YASM_EXE_PATH};$ENV{PATH}")

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Modify-2010-libmpg123.vcxproj-to-use-VS-2015-along-w.patch
)

vcpkg_build_msbuild(
    PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/libmpg123.vcxproj
    RELEASE_CONFIGURATION Release_x86_Dll
    DEBUG_CONFIGURATION Debug_x86_Dll
)

message(STATUS "Installing")
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Debug/libmpg123.dll
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Debug/libmpg123.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Release/libmpg123.dll
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Release/libmpg123.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Debug/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/2010/libmpg123/Release/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/ports/MSVC++/mpg123.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/src/libmpg123/mpg123.h.in
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpg123 RENAME copyright)
vcpkg_copy_pdbs()

message(STATUS "Installing done")
