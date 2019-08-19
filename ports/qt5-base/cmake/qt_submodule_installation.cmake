

function(qt_submodule_installation)
    qt_download_submodule(TARGET_SOURCE_PATH)
    qt_build_submodule(${TARGET_SOURCE_PATH})
    qt_install_copyright(${TARGET_SOURCE_PATH})
endfunction()