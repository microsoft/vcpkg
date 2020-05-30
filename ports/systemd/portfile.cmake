#Still a TODO Build_Depends is wrong
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO systemd/systemd
    REF ea500ac513cf51bcb79a5666f1519499d029428f
    SHA512  6a63536e7af270bbd053796eef48f0732efbd0436597836e769fbfd4a9343a75b924f6b2e6c26cc31874c8ed2e8bded4ae4aeafe9558386bc8c82d38a060fd51
    HEAD_REF master
)


vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    #OPTIONS 

)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)




