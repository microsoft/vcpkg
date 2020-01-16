function(vcpkg_buildpath_length_warning WARNING_LENGTH)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
    if(BUILDTREES_PATH_LENGTH GREATER ${WARNING_LENGTH} AND CMAKE_HOST_WIN32)
            message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
                "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
            )
    endif()
endfunction()