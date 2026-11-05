vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axboe/liburing
    REF "liburing-${VERSION}"
    SHA512 8f2de8b294b14ef2802fe1806ae62a0a4e1f8a52c423e1069a97600a742492eecb1078c435624b9a094a07ae5f706a68e333714c00c904f3d93ca8acf40f81ae
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
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    # liburing's configure script is not Autotools. Its recursive install exposes a path-handling
    # difference observed on Ubuntu 26.04 "Resolute Raccoon":
    # 1. vcpkg-make configures the debug includedir as "${prefix}/../include".
    # 2. liburing's top-level Makefile prepends DESTDIR itself.
    # 3. It forwards that already-staged absolute includedir to the src submake.
    # 4. The src submake calls "install -D" without first creating the intermediate "debug" directory.
    # Resolute's uutils coreutils install rejects a nonexistent "debug" component followed by "..",
    # while GNU coreutils install accepts it. Release needs no replacement because liburing defaults
    # includedir to "${prefix}/include" and vcpkg-make's release prefix is CURRENT_INSTALLED_DIR.
    DEFAULT_OPTIONS_EXCLUDE "^--includedir="
    OPTIONS
        [[--libdevdir=\${prefix}/lib]] # must match libdir
    OPTIONS_DEBUG
        "--includedir=${CURRENT_INSTALLED_DIR}/include"
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

# note: {SOURCE_PATH}/src/Makefile makes liburing.so from liburing.a.
#   For dynamic, remove intermediate file liburing.a when install is finished.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/liburing.a"
                "${CURRENT_PACKAGES_DIR}/lib/liburing.a"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
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
