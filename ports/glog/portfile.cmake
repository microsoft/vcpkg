# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glog-0472b91c5defdf90cff7292e3bf7bd86770a9a0a)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/glog/archive/0472b91c5defdf90cff7292e3bf7bd86770a9a0a.zip"
    FILENAME "glog-0472b91c5defdf90cff7292e3bf7bd86770a9a0a.zip"
    SHA512 24506ad1cc05e8361379b925ecfc8f32cc47692a47598401cca340eb2a528fe28b8b0d3636983056c7910469d105095bd3bacacff6278bffa18d85603c3dbfa8
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-cmake-install-files.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/glog)

file(GLOB GLOG_CMAKE_FILES ${CURRENT_PACKAGES_DIR}/debug/share/glog/*.cmake)
file(COPY ${GLOG_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/glog)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# changes target search path
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/glog/glog-targets-debug.cmake GLOG_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GLOG_DEBUG_MODULE "${GLOG_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glog/glog-targets-debug.cmake "${GLOG_DEBUG_MODULE}")

# remove not used cmake files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake )

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/glog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glog/COPYING ${CURRENT_PACKAGES_DIR}/share/glog/copyright)

