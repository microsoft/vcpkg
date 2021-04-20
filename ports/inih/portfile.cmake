vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO benhoyt/inih
    REF 0b9092e80acc8dc820103c6a0cb9c030e3ca1a32 # r53
    SHA512 beaa6c58c852050733ebd22f46633abfc58723d24d92ac7b339798bc0a512c5e6183970ef13ba6b9e49ff033d1c8b12a93586ce1094b61d9cc24d78f71dff2f9
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
