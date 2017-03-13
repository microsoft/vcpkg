include(vcpkg_common_functions)

set(MPG123_VERSION 1.24.0)
set(MPG123_HASH e7c0d7a103daf496e75a6aa6aca861cfc0ad391f242335990c2360305e567039d24ca3b37a35f79b75749055e255f4692b8b43d2fec332b119223b00e12b0cb7)
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
    PATCHES "${CURRENT_PORT_DIR}/0001-fix-crt-linking.patch")

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
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpg123 RENAME copyright)

message(STATUS "Installing done")
