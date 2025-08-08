vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sahlberg/libsmb2
    REF libsmb2-${VERSION}
    SHA512 db3675d5b6d9242a23b2b259fd3140143edcf5aa8e203b5a4781ce8279046f7f9044a506d1323e9aa6a5ff52eaed4db93dc7a03954af735971ba933bccba6a3e
    HEAD_REF master
)

if(VCPKG_TARGET_IS_IOS)
    list(TRANSFORM FEATURES REPLACE "krb5" "krb5_gssapi")
endif()
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        krb5        ENABLE_LIBKRB5
        krb5_gssapi ENABLE_GSSAPI
    INVERTED_FEATURES
        krb5        CMAKE_DISABLE_FIND_PACKAGE_LibKrb5
        krb5_gssapi CMAKE_DISABLE_FIND_PACKAGE_GSSAPI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_GSSAPI
        CMAKE_DISABLE_FIND_PACKAGE_LibKrb5
        ENABLE_GSSAPI
        ENABLE_LIBKRB5
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME smb2 CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/smb2")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
