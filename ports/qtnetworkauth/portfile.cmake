set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
    # CVE fixes from https://download.qt.io/official_releases/qt/6.7/
    patches/CVE-2024-36048-qtnetworkauth-6.7.diff # fixed in Qt 6.7.1
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
