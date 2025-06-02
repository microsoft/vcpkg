vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF 411a109150b270f23c8c97fa4ec9a0a4a98cdecf
    SHA512 4f604763f05d53e50dec5deaba283fa4f82d5e7a94c7c8142bf422f4c0bc24bcef00666ddbdd820f64c14e552997d6657b6aca79a29e69db43799961b44b2a1a
    HEAD_REF master
    PATCHES 
        fix-find-openssl.patch
        fix_narrowing.patch
        fix-uwp.patch
        fix-clang-dllimport.patch # workaround for https://github.com/microsoft/cpprestsdk/issues/1710
        silence-stdext-checked-array-iterators-warning.patch
        fix-asio-error.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
      brotli CPPREST_EXCLUDE_BROTLI
      compression CPPREST_EXCLUDE_COMPRESSION
      websockets CPPREST_EXCLUDE_WEBSOCKETS
)

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Release"
    ${configure_opts}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXPORT_DIR=share/cpprestsdk
        -DWERROR=OFF
        -DPKG_CONFIG_EXECUTABLE=FALSE
    OPTIONS_DEBUG
        -DCPPREST_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/share" "${CURRENT_PACKAGES_DIR}/lib/share")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpprest/details/cpprest_compat.h"
        "#ifdef _NO_ASYNCRTIMP" "#if 1")
endif()

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
