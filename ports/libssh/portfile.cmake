vcpkg_download_distfile(distfile
    URLS https://www.libssh.org/files/0.12/libssh-${VERSION}.tar.xz
    FILENAME libssh-${VERSION}.tar.xz
    SHA512 92b95d64772906fc0fe497fed4dc34a160f2397f71ef3871dc1ea0fe1e8e3c00df699ed0efdc0b754feb23e2140bda17be41d16aee48ff715487384023fdd467
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${distfile}"
    PATCHES
        0001-export-pkgconfig-file.patch
        0003-no-source-write.patch
        0004-file-permissions-constants.patch
        android-glob-tilde.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pcap    WITH_PCAP
        server  WITH_SERVER
        zlib    WITH_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
        -DWITH_EXAMPLES=OFF
        -DWITH_GSSAPI=OFF
        -DWITH_NACL=OFF
        -DWITH_SYMBOL_VERSIONING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h"
        "#ifdef LIBSSH_STATIC"
        "#if 1"
    )
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libssh)

file(READ "${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake" "
include(CMakeFindDependencyMacro)
if(MINGW32)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_dependency(Threads)
endif()
find_dependency(OpenSSL)
if(\"${WITH_ZLIB}\")
    find_dependency(ZLIB)
endif()
${cmake_config}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
