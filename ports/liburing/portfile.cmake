vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF "liburing-${VERSION}"
    SHA512 ccd40be43d4ea046c63d949cfddd9adb0fda531e3ae4ee17d4639b82a11eda966d8a2afd280b4e6b45f907ea1d53bbd432bfd8ae7a015609e86555a766fc850f
    HEAD_REF master
    PATCHES
        fix-configure.patch     # ignore unsupported options, handle ENABLE_SHARED
        disable-tests-and-examples.patch
)

# https://github.com/axboe/liburing/blob/liburing-2.8/src/Makefile#L13
set(ENV{CFLAGS} "$ENV{CFLAGS} -O3 -Wall -Wextra -fno-stack-protector")

# without this calls to `realpath ${prefix}` inside the build system fail for the debug build if this is the first
# library to be installed
file(MAKE_DIRECTORY "${CURRENT_INSTALLED_DIR}/debug")

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
