vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(NINJA)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY )
get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
get_filename_component(NINJA_DIR "${GPERF}" DIRECTORY )

if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()
if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")
vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")
vcpkg_add_to_path(PREPEND "${GPERF_DIR}")
vcpkg_add_to_path(PREPEND "${NINJA_DIR}")


qt_submodule_installation()