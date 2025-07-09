vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO urcu/userspace-rcu
    REF "v${VERSION}"
    SHA512 838a52fee5a566928766bf897c22be152f351f14928258ab42cdff5f48b621428872e3eb290ef16b10b92cb10fc3e767b35aa534f84893c9a61e471c8ecceb62
    HEAD_REF master
    PATCHES
        fix-assert-include.patch
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
