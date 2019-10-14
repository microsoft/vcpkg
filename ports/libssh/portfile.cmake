include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "WindowsStore not supported")
endif()

set(VERSION 0.7.6)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libssh.org/files/0.7/libssh-${VERSION}.tar.xz"
    FILENAME "libssh-${VERSION}.tar.xz"
    SHA512 2a01402b5a9fab9ecc29200544ed45d3f2c40871ed1c8241ca793f8dc7fdb3ad2150f6a522c4321affa9b8778e280dc7ed10f76adfc4a73f0751ae735a42f56c
)

vcpkg_download_distfile(WINPATCH
    URLS "https://bugs.libssh.org/rLIBSSHf81ca6161223e3566ce78a427571235fb6848fe9?diff=1"
    FILENAME "libssh-f81ca616.patch"
    SHA512 f3f6088f8f1bf8fe6226c1aa7b355d877be7f2aa9482c5e3de74b6a35fc5b28d8f89221d3afa5a5d3a5900519a86e5906516667ed22ad98f058616a8120999cd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        build-one-flavor.patch
        only-one-flavor-threads.patch
        "${WINPATCH}"
        missing-includes.patch
        fix-config-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" WITH_STATIC_LIB)

if(zlib IN_LIST FEATURES)
	set(WITH_ZLIB ON)
else()
	set(WITH_ZLIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_STATIC_LIB=${WITH_STATIC_LIB}
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTING=OFF
        -DWITH_NACL=OFF
        -DWITH_GSSAPI=OFF
        -DWITH_ZLIB=${WITH_ZLIB}
        -DCMAKE_INSTALL_DIR=share/libssh
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/static/ssh.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/static/ssh.lib ${CURRENT_PACKAGES_DIR}/lib/ssh.lib)
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/static/ssh.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/static/ssh.lib ${CURRENT_PACKAGES_DIR}/debug/lib/ssh.lib)
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(READ ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h _contents)
    string(REPLACE "#ifdef LIBSSH_STATIC" "#if 1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h "${_contents}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/static ${CURRENT_PACKAGES_DIR}/debug/lib/static)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# The installed cmake config files are nonfunctional (0.7.5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh)