function(vcpkg_boost_copy_headers)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH" "")

    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to vcpkg_boost_copy_headers.")
    endif()

    message(STATUS "Copying headers")
    file(COPY
        ${arg_SOURCE_PATH}/include/boost
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
        NO_SOURCE_PERMISSIONS
    )
    message(STATUS "Copying headers done")

    file(INSTALL
        ${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/usage
        ${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/copyright
        DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    )
endfunction()
