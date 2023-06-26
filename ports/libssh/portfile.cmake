vcpkg_download_distfile(distfile
    URLS https://www.libssh.org/files/0.10/libssh-${VERSION}.tar.xz
    FILENAME libssh-${VERSION}.tar.xz
    SHA512 2b758f9df2b5937865d4aee775ffeafafe3ae6739a89dfc470e38c7394e3c3cb5fcf8f842fdae04929890ee7e47bf8f50e3a38e82dfd26a009f3aae009d589e0
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${distfile}"
    PATCHES
        0001-export-pkgconfig-file.patch
        0002-mingw_for_Android.patch
        0003-create_symlink_unix_only.patch
        0004-file-permissions-constants.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mbedtls WITH_MBEDTLS
        zlib    WITH_ZLIB
)

if (VCPKG_TARGET_IS_ANDROID)
    set(EXTRA_ARGS "-DWITH_SERVER=FALSE"
                   "-DWITH_PCAP=FALSE")
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EXTRA_ARGS}
        ${FEATURE_OPTIONS}
        -DWITH_EXAMPLES=OFF
        -DUNIT_TESTING=OFF
        -DCLIENT_TESTING=OFF
        -DSERVER_TESTING=OFF
        -DWITH_NACL=OFF
        -DWITH_GSSAPI=OFF
        -DWITH_SYMBOL_VERSIONING=OFF)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
#Fixup pthread naming
if(NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libssh.pc" "-lpthread" "-lpthreadVC3d")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libssh.pc" "-lpthread" "-lpthreadVC3")
endif()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/libssh/libssh.h"
        "#ifdef LIBSSH_STATIC"
        "#if 1"
    )
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libssh)
file(READ "${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake" cmake_config)
if(VCPKG_TARGET_IS_WINDOWS)
    string(REPLACE ".dll" ".lib" cmake_config "${cmake_config}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libssh/libssh-config.cmake"
"include(CMakeFindDependencyMacro)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_dependency(Threads)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
