set(VCPKG_TARGET_ARCHITECTURE x86) 

vcpkg_download_distfile(
    ARCHIVE
    URLS "http://www.crosswire.org/ftpmirror/pub/sword/source/sword.tar.gz"
    FILENAME "sword.tar.gz"
    SHA512 9ed3fbb5024af1f93b1473bae0d95534d02a5b00b3c9d41a0f855cee8106dc4e330844080adbee7c3f74c0e5ce1480bf16c87c842421337a341f641bae11137f
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        vcpkg.patch
)

vcpkg_install_msbuild(
    SOURCE_PATH "${SOURCE_PATH}"
	INCLUDES_SUBPATH "include"
	LICENSE_SUBPATH "LICENSE"
	PROJECT_SUBPATH "lib/vcppmake/libsword.sln"
	RELEASE_CONFIGURATION "Release"
	DEBUG_CONFIGURATION "Debug"
	PLATFORM "Win32"
	USE_VCPKG_INTEGRATION
	ALLOW_ROOT_INCLUDES
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/zlib.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/zconf.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/include/Makefile")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
