

function(qt_submodule_installation)
    qt_download_submodule(OUT_SOURCE_PATH TARGET_SOURCE_PATH ${ARGV})
    qt_build_submodule(${TARGET_SOURCE_PATH})
    qt_install_copyright(${TARGET_SOURCE_PATH})
endfunction()