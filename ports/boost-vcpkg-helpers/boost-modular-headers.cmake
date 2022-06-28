function(boost_modular_headers)
    cmake_parse_arguments(_bm "" "SOURCE_PATH" "" ${ARGN})

    if(NOT DEFINED _bm_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to boost_modular_headers.")
    endif()

    message(STATUS "Copying headers")
    file(
        COPY ${_bm_SOURCE_PATH}/include/boost
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
    message(STATUS "Copying headers done")

    file(INSTALL
        ${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/usage
        ${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/copyright
        DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    )
endfunction()
