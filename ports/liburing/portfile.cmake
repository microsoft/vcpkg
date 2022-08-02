vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF 41a61c97c2e3df4475c93fdf5026d575ce3f1377 #liburing-2.1
    SHA512 adbfee9a775ff0977c192b52f5cc2c52b2b40bf5e7c0c1153d88b7767889c7c8a39863da0bce3ebed0f396a453e879633ecf1c79f4f2c4f89407ff896d8b6222
    HEAD_REF master
    PATCHES
        fix-spec-version.patch  # update version value for pkgconfig(.pc) files
        fix-configure.patch     # ignore unsupported options, handle ENABLE_SHARED
)

# note: check ${SOURCE_PATH}/liburing.spec before updating configure options
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# note: {SOURCE_PATH}/src/Makefile makes liburing.so from liburing.a.
#   For dynamic, remove intermediate file liburing.a when install is finished.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/liburing.a"
                "${CURRENT_PACKAGES_DIR}/lib/liburing.a"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man2")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man7")
