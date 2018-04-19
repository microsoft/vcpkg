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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/restinio-0.4.5-vcpkg/dev/restinio)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/ngrodzitski/restinio-vcpkg-archives-tesst-2018/downloads/restinio-0.4.5-vcpkg.zip"
    FILENAME "restinio-0.4.5-vcpkg.zip"
    SHA512 be6e68d43fb28dea0bc4dd2052c2734795d9e749c2cd09731592e1bac54d4d0a543e13b981805d1fe26e326e48bfca8f7e5d87f137c8e9bb4a2756ef0942b232
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
	    -DRESTINIO_USE_BOOST_ASIO=none
	    -DRESTINIO_STAND_ALONE_ASIO_DEFINES=\-DASIO_STANDALONE=1\ \-DASIO_HAS_STD_CHRONO=1\ \-DASIO_DISABLE_STD_STRING_VIEW=1
		-DRESTINIO_INSTALL=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/lib 
    ${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib
	)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/restinio")

# Handle copyright
file(COPY ${SOURCE_PATH}/../../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restinio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restinio/LICENSE ${CURRENT_PACKAGES_DIR}/share/restinio/copyright)