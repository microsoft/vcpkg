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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dcmtk-DCMTK-3.6.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DCMTK/dcmtk/archive/DCMTK-3.6.3.zip"
    FILENAME "3.6.3.zip"
    SHA512 4b6770d0661ccbc24f078cde6ca3fc09ef4e66839f3884646395f686a1b7798ab6e490efcc725e53d41125068fe3b47f305e0f4f57c6f8f1040acc37630e26d5
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/dcmtk.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DDCMTK_WITH_DOXYGEN=OFF
        -DDCMTK_WITH_ZLIB=OFF
        -DDCMTK_WITH_OPENSSL=OFF
        -DDCMTK_WITH_PNG=OFF
        -DDCMTK_WITH_TIFF=OFF
        -DDCMTK_WITH_XML=OFF
        -DDCMTK_WITH_ICONV=OFF
        -DDCMTK_FORCE_FPIC_ON_UNIX=ON
        -DDCMTK_OVERWRITE_WIN32_COMPILER_FLAGS=OFF
        -DDCMTK_ENABLE_BUILTIN_DICTIONARY=ON
        -DDCMTK_ENABLE_PRIVATE_TAGS=ON
        -DBUILD_APPS=OFF
        -DDCMTK_ENABLE_CXX11=ON 
        -DCMAKE_DEBUG_POSTFIX="d"
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets() # combines release and debug build configurations

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(READ ${CURRENT_PACKAGES_DIR}/debug/share/DCMTKTargets-debug.cmake DCMTK_CONFIG_LIB)
  string(REPLACE "PREFIX}/lib"
                 "PREFIX}/debug/lib" DCMTK_CONFIG_LIB "${DCMTK_CONFIG_LIB}")
  string(REPLACE "PREFIX}/bin"
                 "PREFIX}/debug/bin" DCMTK_CONFIG_LIB "${DCMTK_CONFIG_LIB}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/DCMTKTargets-debug.cmake "${DCMTK_CONFIG_LIB}")
endif()

# the following lines should be called only after the cmake config has been built properly
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/dcmtk RENAME copyright)
