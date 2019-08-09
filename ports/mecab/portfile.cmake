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

if (UWP OR ARM OR ARM64)
    message(FATAL_ERROR "mecab does not support on this platform")
endif()

include(vcpkg_common_functions)
#https://github.com/taku910/mecab/archive/master.zip
set(MECAB_VERSION 0.996)
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO taku910/mecab
	REF master
	SHA512 2a7f1d159ddca846357b5bcab2d2b5de2e6a27dca4301cdd1cc52c155c352f9c7030b77d1187afe9c0a7f1b131a1acdcc40ee81ce7ba5c0fa6b2325c56676353
	HEAD_REF master
	PATCHES
		fix_wpath_unsigned.patch
)

# vcpkg_download_distfile(ARCHIVE
    # URLS "https://github.com/taku910/mecab/archive/master.zip"
    # FILENAME "mecab-${MECAB_VERSION}.zip"
    # SHA512 28782e6cacff49fdafa6896c660462587c5aa7e26fe249f55d5c23472353e4ee19473eda5368c5f2cc37e85f7797c7bba4fb31bd151f715ed99ad7b61d39f068
# )

# #set(ARCHIVE "D:/software/vcpkg/downloads/mecabsrc.zip")
# message(STATUS "Begin to extract files ...")
# vcpkg_extract_source_archive_ex(
    # OUT_SOURCE_PATH SOURCE_PATH
    # ARCHIVE ${ARCHIVE} 
    # # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # # REF 1.0.0
    # # (Optional) Read the docs for how to generate patches at: 
    # # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    # # PATCHES
    # #   001_port_fixes.patch
    # #   002_more_port_fixes.patch
	# PATCHES
		# fix_wpath_unsigned.patch
# )
message(STATUS "source path is : ${SOURCE_PATH}")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/mecab/src)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/mecab/src)
file(COPY ${SOURCE_PATH}/mecab/COPYING DESTINATION ${SOURCE_PATH}/mecab/src)

#message(STATUS "MAKE_CURRENT_LIST_DIR : ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "CURRENT_PACKAGES_DIR is : ${CURRENT_PACKAGES_DIR}")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/mecab/src
)

# vcpkg_configure_cmake(
    # SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # # OPTIONS_RELEASE -DOPTIMIZE=1
    # # OPTIONS_DEBUG -DDEBUGGABLE=1
# )

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(COPY ${SOURCE_PATH}/mecab/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mecab)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mecab/COPYING ${CURRENT_PACKAGES_DIR}/share/mecab/copyright)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mecab RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME mecab)
