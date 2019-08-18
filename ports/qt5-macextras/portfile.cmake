include(vcpkg_common_functions)

if (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(FATAL_ERROR "qt5-macextras only support OSX.")
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_ports_helper.cmake)

qt_ports_helper(qtmacextras 56887c2a2d20c41a133af87aec8975e17c6335ffc51093f23a904e02a78f59a8117c7932827ca5dd33f538360e6fd9cfc9d0091c6f4c1e0b96528b5324c74033)
