include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.3
    SHA512 e831f4f918f08fd5f799501efc0e23b8d404478651634f5e7b35f8ebcc29d91abc447ab20da062dde5be75e18cb39ffea708688e6534f7ab257b949f9c53ddc8
    HEAD_REF master)

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Denable-glx=no
        -Denable-egl=no)
vcpkg_install_meson()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libepoxy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libepoxy/COPYING ${CURRENT_PACKAGES_DIR}/share/libepoxy/copyright)
