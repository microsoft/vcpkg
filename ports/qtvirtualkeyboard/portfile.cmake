set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES hunspell_include_path_fix.patch)

if("hunspell" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_vkb_hunspell:STRING=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_vkb_hunspell=no)
endif()
if("t9write" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_vkb_handwriting=t9write)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_vkb_handwriting=no)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                                        -DINPUT_vkb_style:STRING=default
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG -DFEATURE_vkb_record_trace_input=ON
                                             -DFEATURE_vkb_sensitive_debug=ON
                    )
