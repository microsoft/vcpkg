include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "qt5-winextras only support Windows.")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qtwinextras 4d972884bce7736d2a6e6b8d61291647cdf54a175cb6d0fca102e389074084e0f3d25dec35b2b8df2188760ebeee4b2b7f0158ebc37a0c6c1e208d7b10d2a778)
