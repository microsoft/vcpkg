if(VCPKG_TARGET_IS_ANDROID)
    # tbd

elseif(VCPKG_TARGET_IS_LINUX)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_determine_target_triplet(triplet COMPILER_NAME "cc") ]]
        triplet ""
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_determine_target_triplet(triplet COMPILER_NAME "aarch64-linux-gnu-gcc") ]]
        triplet "aarch64-linux-gnu"
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_determine_target_triplet(triplet COMPILER_NAME "i686-linux-gnu-clang") ]]
        triplet "i686-linux-gnu"
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_determine_target_triplet(triplet COMPILER_NAME "x86_64-linux-gnu-gcc-13") ]]
        triplet "x86_64-linux-gnu"
    )

elseif(VPCKG_TARGET_IS_OSX)
    # tbd

elseif(VCPKG_TARGET_IS_UWP)
    # tbd

elseif(VCPKG_TARGET_IS_WINDOWS)
    # tbd

endif()
