cmake_minimum_required(VERSION 3.21)

set(CMAKE_INSTALL_PREFIX "/usr")

project(vcpgk_lib_paths LANGUAGES C CXX)


include(GNUInstallDirs)

set(export_vars CMAKE_C_LIBRARY_ARCHITECTURE
                CMAKE_CXX_LIBRARY_ARCHITECTURE
                CMAKE_LIBRARY_ARCHITECTURE
                CMAKE_LIBRARY_ARCHITECTURE_REGEX
                CMAKE_INSTALL_LIBDIR
                CMAKE_INSTALL_INCLUDEDIR
                CMAKE_INSTALL_DATAROOTDIR
                CMAKE_INSTALL_FULL_LIBDIR
                CMAKE_INSTALL_FULL_INCLUDEDIR
                CMAKE_INSTALL_FULL_DATAROOTDIR

)
set(output "")
foreach(var IN LISTS export_vars)
    string(APPEND output "set(VCPKG_DETECTED_${var} \"${${var}}\")\n")
endforeach()

if(DEFINED OUTPUT_FILE)
    file(WRITE "${OUTPUT_FILE}" "${output}")
endif()