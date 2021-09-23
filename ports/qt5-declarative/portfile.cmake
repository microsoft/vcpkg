include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
set(BUILD_OPTIONS "")
if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_MINGW)
    set(ENV{MSYS2_ARG_CONV_EXCL} "--foreign-types=")
    list(APPEND BUILD_OPTIONS "-no-d3d12")
endif()
qt_submodule_installation(
    # PATCHES must be first, or vcpkg_configure_qmake will take it as BUILD_OPTIONS.
    PATCHES limits_include.patch
    BUILD_OPTIONS ${BUILD_OPTIONS}
)
