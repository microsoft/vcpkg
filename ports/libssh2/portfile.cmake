vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF "libssh2-${VERSION}"
    SHA512 8ae38d76e7fae82843c7c6990760ad5827cb55e2aba096f684b832016614d76983d1871ae0857ba28efcb9fd65018ae0b34420f6841da6bb6c6ccebd9689ec0f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib    ENABLE_ZLIB_COMPRESSION
    INVERTED_FEATURES
        zlib    CMAKE_DISABLE_FIND_PACKAGE_ZLIB # for use by the cryto backend
)
if("openssl" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DCRYPTO_BACKEND=OpenSSL")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_OPTIONS "-DCRYPTO_BACKEND=WinCNG")
else()
    message(FATAL_ERROR "Port ${PORT} only supports OpenSSL and WinCNG crypto backends.")
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND FEATURE_OPTIONS "-DBUILD_STATIC_LIBS:BOOL=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_DEBUG_LOGGING=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libssh2)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef LIBSSH2_WIN32" "if 1")
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef _WINDLL" "if 1")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libssh2.h" "ifdef _WINDLL" "if 0")
    endif()
    if(VCPKG_TARGET_STATIC_LIBRARY_PREFIX STREQUAL "")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libssh2.pc" " -lssh2" " -llibssh2")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libssh2.pc" " -lssh2" " -llibssh2")
        endif()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
