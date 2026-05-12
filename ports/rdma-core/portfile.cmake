vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-rdma/rdma-core
    REF "v${VERSION}"
    SHA512 0251340e2b3b90562f903bcc26d489516c6efba3179423932c6b9c2e8dd2c6ef934fa476d9963db26544ddb5232e0da94574774e578ea6c0268c57961a0aeb47
    HEAD_REF master
    PATCHES
        0001-disable-tests.patch
        0002-disable-examples.patch
        0003-disable-documentation.patch
        0004-disable-infiniband-diags.patch
        0005-disable-srp-daemon.patch
        0006-disable-kernel-boot.patch
        0007-disable-librspreload.patch
        0008-enable-static-libs-only.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_get_vcpkg_installed_python(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_RESOLVE_NEIGH=OFF
        -DNO_MAN_PAGES=ON
        -DNO_PYVERBS=ON
        -DENABLE_STATIC="${ENABLE_STATIC}"
        -DVCPKG_LOCK_FIND_PACKAGE_PythonLibs=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Systemd=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_UDev=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_cython=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_pandoc=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_rst2man=OFF
        -DPython_EXECUTABLE=${PYTHON3}
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_PythonLibs
        VCPKG_LOCK_FIND_PACKAGE_cython
        VCPKG_LOCK_FIND_PACKAGE_pandoc
        VCPKG_LOCK_FIND_PACKAGE_rst2man
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libexec")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING.md"
    "${SOURCE_PATH}/COPYING.BSD_MIT"
    "${SOURCE_PATH}/COPYING.GPL2"
    "${SOURCE_PATH}/ccan/LICENSE.CCO"
    "${SOURCE_PATH}/ccan/LICENSE.MIT"
    "${SOURCE_PATH}/providers/hfi1verbs/hfiverbs.h"
    "${SOURCE_PATH}/providers/ipathverbs/COPYING"
    "${SOURCE_PATH}/COPYING.BSD_FB"
)
