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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gainput-1.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://github.com/jkuhlmann/gainput/archive/v1.0.0.zip"
    FILENAME "gainput-1.0.0.zip"
    SHA512 dab221290560298693f54bebced1da5ec3dfae2d2adbfd6ceb17b5b28dc2a637a49e479d49fe98680915b29beb5dd2d5c74258598233a053230696186593c88e
)
vcpkg_extract_source_archive(${ARCHIVE})



vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
	OPTIONS
		-DGAINPUT_TESTS=OFF
		-DGAINPUT_SAMPLES=OFF
	# Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gainput RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/gainputstatic.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gainputstatic.lib ${CURRENT_PACKAGES_DIR}/lib/gainput.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gainputstaticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/gainputd.lib)
    endif()
endif()
