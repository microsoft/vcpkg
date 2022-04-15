

function(qt_submodule_installation)
    cmake_parse_arguments(_csc
        ""
        "OUT_SOURCE_PATH"
         "PATCHES;OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG"
         ${ARGN}
    )
    qt_download_submodule(OUT_SOURCE_PATH TARGET_SOURCE_PATH PATCHES ${_csc_PATCHES})
    if(QT_UPDATE_VERSION)
        SET(VCPKG_POLICY_EMPTY_PACKAGE enabled PARENT_SCOPE)
    else()
        qt_build_submodule(${TARGET_SOURCE_PATH}
            OPTIONS ${_csc_OPTIONS}
            OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
            OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
            BUILD_OPTIONS ${_csc_BUILD_OPTIONS}
            BUILD_OPTIONS_RELEASE ${_csc_BUILD_OPTIONS_RELEASE}
            BUILD_OPTIONS_DEBUG ${_csc_BUILD_OPTIONS_DEBUG}
        )
        qt_install_copyright(${TARGET_SOURCE_PATH})
    endif()
    if(DEFINED _csc_OUT_SOURCE_PATH)
        set(${_csc_OUT_SOURCE_PATH} ${TARGET_SOURCE_PATH} PARENT_SCOPE)
    endif()
endfunction()