file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    "${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_get_python_packages.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/python310._pth"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

include("${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_get_python_packages.cmake")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(python_dir "${PYTHON3}" DIRECTORY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/python310._pth" DESTINATION "${python_dir}")
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES numpy)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
