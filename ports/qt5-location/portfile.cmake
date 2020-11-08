vcpkg_download_distfile(
    PATCH
    URLS "https://codereview.qt-project.org/gitweb?p=qt%2Fqtlocation.git;a=commitdiff_plain;h=6b2cf7e9d150b7be709fcd688c5045949cedc3d9;hp=7769ea903f87efc4ad55530a2749f104eddff2e4"
    SHA512 99d16fb0e88a2250de3896815abbb22ff5aa4d3920397610cf37be701fe03a7241e0586aae5b85755aeb958926183c96a0482a8837335d20a2171ebb2a66e640
    FILENAME qt5-location-rename-99d16fb0.patch
)

message(STATUS "${PORT} has a spurious failure in which it is unable to create a parent directory! Just retry.")
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(PATCHES "${PATCH}")
