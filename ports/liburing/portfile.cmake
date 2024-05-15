vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF "liburing-${VERSION}"
    SHA512 e5ce61e80fe90f95128e62abfec7771912fe98674f7dbf5806ed61cb386adecedf495c50cb77b684f5b61f48deb44ccb4e3ba032613920213366132bbbc908db
    HEAD_REF master
    PATCHES
        fix-configure.patch     # ignore unsupported options, handle ENABLE_SHARED
        disable-tests-and-examples.patch
)

# note: check ${SOURCE_PATH}/liburing.spec before updating configure options
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    OPTIONS
        [[--libdevdir=\${prefix}/lib]] # must match libdir
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
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
