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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/src/readline/5.0/readline-5.0-src)

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/gnuwin32/readline/5.0-1/readline-5.0-1-src.zip"
    FILENAME "readline-5.0-1-src.zip"
    SHA512 f5bf7fe3211c3ca971684b8910216ab9e460d97e1d572c1c263e7648079a077d4af32621fadf3ca7459cb35f9c0e90dbd9c4b2d94af4578adf8fc6c5f0e9bd8f
)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

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
