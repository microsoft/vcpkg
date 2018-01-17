include(vcpkg_common_functions)

set(MPG123_VERSION 1.25.8)
set(MPG123_HASH f226317dddb07841a13753603fa13c0a867605a5a051626cb30d45cfba266d3d4296f5b8254f65b403bb5eef6addce1784ae8829b671a746854785cda1bad203)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpg123-${MPG123_VERSION})

#architecture detection
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
   set(MPG123_ARCH Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   set(MPG123_ARCH x64)
else()
   message(FATAL_ERROR "unsupported architecture")
endif()

#linking
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(MPG123_CONFIGURATION_SUFFIX _Dll)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/mpg123/mpg123/${MPG123_VERSION}/mpg123-${MPG123_VERSION}.tar.bz2"
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH} 
    PATCHES
        "${CURRENT_PORT_DIR}/0001-fix-crt-linking.patch"
        "${CURRENT_PORT_DIR}/0002-fix-x86-build.patch")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/libmpg123.vcxproj
    RELEASE_CONFIGURATION Release_x86${MPG123_CONFIGURATION_SUFFIX}
    DEBUG_CONFIGURATION Debug_x86${MPG123_CONFIGURATION_SUFFIX}
)

message(STATUS "Installing")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.dll
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.dll
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
else()
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug_x86/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release_x86/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/ports/MSVC++/mpg123.h
    ${SOURCE_PATH}/src/libmpg123/fmt123.h
    ${SOURCE_PATH}/src/libmpg123/mpg123.h.in
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpg123 RENAME copyright)

message(STATUS "Installing done")
