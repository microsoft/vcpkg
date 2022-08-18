function(vcpkg_apply_patches)
    z_vcpkg_deprecation_message("vcpkg_apply_patches has been deprecated in favor of the `PATCHES` argument to `vcpkg_from_*`.")

    cmake_parse_arguments(PARSE_ARGV 0 "arg" "QUIET" "SOURCE_PATH" "PATCHES")

    if(arg_QUIET)
        set(quiet "QUIET")
    else()
        set(quiet)
    endif()

    z_vcpkg_apply_patches(
        SOURCE_PATH "${arg_SOURCE_PATH}"
        ${quiet}
        PATCHES ${arg_PATCHES}
    )
endfunction()
