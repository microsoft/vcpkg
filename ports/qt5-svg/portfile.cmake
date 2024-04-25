include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(
    PATCHES
        "CVE-2023-32573-qtsvg-5.15.diff" # CVE fix from https://download.qt.io/official_releases/qt/5.15/
        "static_svg_link_fix.patch"
)
