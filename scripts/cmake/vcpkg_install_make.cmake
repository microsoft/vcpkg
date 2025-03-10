function(vcpkg_install_make)
    vcpkg_build_make(
        ${ARGN}
        ENABLE_INSTALL
    )
endfunction()
