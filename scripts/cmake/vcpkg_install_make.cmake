function(vcpkg_install_make)
    vcpkg_build_make(
        ${ARGN}
        LOGFILE_ROOT
        ENABLE_INSTALL
    )
endfunction()
