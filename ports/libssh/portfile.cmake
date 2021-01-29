vcpkg_fail_port_install(ON_TARGET "UWP")

set(VERSION 0.9.5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libssh.org/files/0.9/libssh-${VERSION}.tar.xz"
    FILENAME "libssh-${VERSION}.tar.xz"
    SHA512 64e692a0bfa7f73585ea7b7b8b1d4c9a7f9be59565bfd4de32ca8cd9db121f87e7ad51f5c80269fbd99545af34dcf1894374ed8a6d6c1ac5f8601c026572ac18
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    mbedtls WITH_MBEDTLS
    zlib    WITH_ZLIB
)

if (VCPKG_TARGET_IS_ANDROID)
	set(EXTRA_ARGS "-DWITH_SERVER=FALSE"
			"-DWITH_PCAP=FALSE"
			)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${EXTRA_ARGS}
        ${FEATURE_OPTIONS}
        -DWITH_EXAMPLES=OFF
        -DUNIT_TESTING=OFF
        -DCLIENT_TESTING=OFF
        -DSERVER_TESTING=OFF
        -DWITH_NACL=OFF)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    vcpkg_replace_string(
	    ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h 
	    "#ifdef LIBSSH_STATIC"
	    "#if 1"
	)	
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(
	    ${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake
	    ".dll"
	    ".lib"
	)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
