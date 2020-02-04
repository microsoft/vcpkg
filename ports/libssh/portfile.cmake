vcpkg_fail_port_install(ON_TARGET "UWP")

set(VERSION 0.9.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libssh.org/files/0.9/libssh-${VERSION}.tar.xz"
    FILENAME "libssh-${VERSION}.tar.xz"
    SHA512 6e59718565daeca6d224426cc1095a112deff9af8e0b021917e04f08bb7409263c35724de95f591f38e26f0fb3bbbbc69b679b6775edc21dec158d241b076c6f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
                     FEATURES
                         mbedtls WITH_MBEDTLS
                         zlib WITH_ZLIB
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
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

    file(READ ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h _contents)
    string(REPLACE "#ifdef LIBSSH_STATIC" "#if 1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h "${_contents}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(READ ${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake _contents)
    string(REPLACE ".dll" ".lib" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake "${_contents}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh)
