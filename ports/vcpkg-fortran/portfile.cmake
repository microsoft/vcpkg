set(FUNCTION_NAME x_vcpkg_find_fortran)

if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/${FUNCTION_NAME}.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_load_environment_from_batch.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
