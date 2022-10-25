include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

vcpkg_list(SET _patches
    "patches/unrequire_quick.patch"
)
if("declarative" IN_LIST FEATURES)
    list(APPEND _patches
        "patches/require_quick.patch"
    )
endif()

qt_submodule_installation(PATCHES ${_patches})
