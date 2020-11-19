vcpkg_download_distfile(
    PATCH
    URLS "https://github.com/qt/qtlocation/commit/6b2cf7e9d150b7be709fcd688c5045949cedc3d9.diff"
    SHA512 7ca02812957969f26919b1566469d4187b0dc7e16091544b1b4583d05337ed7c8983d6dbc22f8d61ce54dd56ab4a5662fea7017fbdc802e4e0bc6e4bc511fabe
    FILENAME qt5-location-rename-99d16fb0.patch
)

message(STATUS "${PORT} has a spurious failure in which it is unable to create a parent directory! Just retry.")
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(PATCHES "${PATCH}")
