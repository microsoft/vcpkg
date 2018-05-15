# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/readline-vs/src/readline/5.0/readline-5.0-src)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/lltcggie/readline/archive/vs.zip"
    FILENAME "readline-5.0-1-src.zip"
    SHA512 c67908b9c868aa611a48dfc4db43718169cbdc6784107beb22cd1a4d28f0c4aa88f30cae0839a530c481c74173e1d7a2bf0000596099ed9b940c05c9dc7d5ebc
)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH})

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(LIBVPX_CRT_LINKAGE --enable-static-msvcrt)
    set(LIBVPX_CRT_SUFFIX mt)
else()
    set(LIBVPX_CRT_SUFFIX md)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()

# Copy headers
file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include/readline)
    
file(GLOB headers "${SOURCE_PATH}/*.h")
file(COPY ${headers} DESTINATION ${CURRENT_PACKAGES_DIR}/include/readline)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/readline RENAME copyright)
