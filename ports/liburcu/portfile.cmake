vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO urcu/userspace-rcu
    REF "v${VERSION}"
    SHA512 40649c19af80da95d4463600ae06295505ed1865dbcffce7ff201de5ec025a57530ee745184151296669cc64e99aaef16958452e6dbab7b8a655b2e911dafd72
    HEAD_REF master
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
        "${SOURCE_PATH}/LICENSES/LGPL-2.1-or-later.txt"
        "${SOURCE_PATH}/LICENSES/LicenseRef-Boehm-GC.txt"
        "${SOURCE_PATH}/LICENSES/MIT.txt"
)
