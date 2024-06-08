include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(PATCHES 
    # CVE fixes from https://download.qt.io/official_releases/qt/5.15/
    patches/CVE-2024-36048-qtnetworkauth-5.15.diff
)