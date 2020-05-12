

function(qt_submodule_installation)
    qt_download_submodule(OUT_SOURCE_PATH TARGET_SOURCE_PATH ${ARGV})
    if(QT_UPDATE_VERSION)
        SET(VCPKG_POLICY_EMPTY_PACKAGE enabled PARENT_SCOPE)
    else()
        qt_build_submodule(${TARGET_SOURCE_PATH} ${ARGV})
        qt_install_copyright(${TARGET_SOURCE_PATH})
    endif()
endfunction()