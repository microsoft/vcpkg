set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

set(FUNCTION_NAME x_vcpkg_find_fortran)

if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    # message(WARNING "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
    # NOTE: Interessting case here: Would need to go from target --> host --> target. 
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/${FUNCTION_NAME}.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${VCPKG_ROOT_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)

