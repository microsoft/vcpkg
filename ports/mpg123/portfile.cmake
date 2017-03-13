if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpg123-1.23.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/mpg123/mpg123/1.23.3/mpg123-1.23.3.tar.bz2"
    FILENAME "mpg123-1.23.3.tar.bz2"
    SHA512 a5ebfb36223a3966386bc8e5769b8543861872d20f9de037d07857e857000f20e198e0b1db04bdc56b18b19d5b4027d8261a104af0216d6ea45274b21a18dda4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Modify-2010-libmpg123.vcxproj-to-use-VS-2015-along-w.patch
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/libmpg123.vcxproj
    RELEASE_CONFIGURATION Release_x86_Dll
    DEBUG_CONFIGURATION Debug_x86_Dll
)

message(STATUS "Installing")
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Debug/libmpg123.dll
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Debug/libmpg123.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Release/libmpg123.dll
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Release/libmpg123.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Debug/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2010/libmpg123/Release/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/mpg123.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/src/libmpg123/mpg123.h.in
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpg123 RENAME copyright)
vcpkg_copy_pdbs()

message(STATUS "Installing done")
