vcpkg_download_distfile(SYNC_ZCRX_CHANGES_1
    URLS https://github.com/axboe/liburing/commit/48d8d54e524a9c37e0cc52921bb41070156a597f.patch?full_index=1
    SHA512 d16a6622538256c163785c0eaa89dd2ac53c5e7f1a93fc471198325628305d3d494ca3716233e666d0589d3d0a9e67708f6e8c2b46cda3bc4588fde11e091749
    FILENAME liburing-sync-zcrx-changes-1.patch
)

vcpkg_download_distfile(SYNC_ZCRX_CHANGES_2
    URLS https://github.com/axboe/liburing/commit/ce3a65747d43a405cc19a630d5f8a0f613293f5c.patch?full_index=1
    SHA512 571d0e8cdc5334208947de750b6458277653d64235dfeae99ae130e8de61e9ababc5827232eae9db3f44743fd93dd22f1cd248ec2ea22a035dd7efd10f18b2bd
    FILENAME liburing-sync-zcrx-changes-2.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF "liburing-${VERSION}"
    SHA512 f27233e6128444175b18cd1d45647acdd27b906a8cd561029508710e443b44416b916cad1b2c1217e23d9a5ffb5ba68b119e9c812eae406650fbd10bf26c2fa5
    HEAD_REF master
    PATCHES
        fix-configure.patch     # ignore unsupported options, handle ENABLE_SHARED
        disable-tests-and-examples.patch
        ${SYNC_ZCRX_CHANGES_1}
        ${SYNC_ZCRX_CHANGES_2}
        add-basic-support.patch # https://github.com/axboe/liburing/commit/d7ec4ce3421fbbdaba07426d589b72e204ac92e9
)

# https://github.com/axboe/liburing/blob/liburing-2.8/src/Makefile#L13
set(ENV{CFLAGS} "$ENV{CFLAGS} -O3 -Wall -Wextra -fno-stack-protector")

# note: check ${SOURCE_PATH}/liburing.spec before updating configure options
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    DETERMINE_BUILD_TRIPLET
    OPTIONS
        [[--libdevdir=\${prefix}/lib]] # must match libdir
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

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

# Cf. README
vcpkg_install_copyright(COMMENT [[
All software contained from liburing is dual licensed LGPL and MIT, see
COPYING and LICENSE, except for a header coming from the kernel which is
dual licensed GPL with a Linux-syscall-note exception and MIT, see
COPYING.GPL and <https://spdx.org/licenses/Linux-syscall-note.html>.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.GPL"
)
