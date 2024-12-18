vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sahlberg/libsmb2
    REF libsmb2-6.1
    SHA512 7f481b22f90b82d19c6bb29537ef10229b3ff4aff3d46dff5b11ee22c9c0410f1d58f466cf0774507d1d6f03c06dd82b223b1f4be75da239402e57749382fe5f
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	FEATURES
        gssapi ENABLE_GSSAPI
        krb5   ENABLE_LIBKRB5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
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
