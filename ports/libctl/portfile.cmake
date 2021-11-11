message(STATUS "${PORT} currently requires the following library from the system package manager:
    guile-2.2-dev
This can be installed on Ubuntu systems via sudo apt install guile-2.2-dev")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NanoComp/libctl
    REF aa56a410f33fb2fd80605faf35dfa7906785edef
    SHA512 0351f35e433089bf8437ab17eaa0cf13d9d578776806011e1ecfe48cda769ebc21801f0e5b31bf3f80a62ceae170f0d5e9c9b817e01e39bffd8c062b3ff1731c
    HEAD_REF master
)

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        --enable-debug
)

vcpkg_install_make()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
