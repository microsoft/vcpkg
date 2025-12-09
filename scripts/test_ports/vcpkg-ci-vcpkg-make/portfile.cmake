set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
include("${CURRENT_HOST_INSTALLED_DIR}/share/unit-test-cmake/test-macros.cmake")

if("scripts-cl-cpp-wrapper" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-scripts-cl_cpp_wrapper.cmake")
endif()

if("vcpkg-make-cl-cpp-wrapper" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg-make-cl_cpp_wrapper.cmake")
endif()

if("z-vcpkg-make-prepare-compile-flags" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_prepare_compile_flags.cmake")
endif()

if("z-vcpkg-make-normalize-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_normalize_arch.cmake")
endif()

if("z-vcpkg-make-determine-host-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_host_arch.cmake")
endif()

if("z-vcpkg-make-determine-target-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_target_arch.cmake")
endif()

if("z-vcpkg-make-determine-target-triplet" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_target_triplet.cmake")
endif()

if("z-vcpkg-make-z-adapt-lib-link-names" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_adapt_lib_link_names.cmake")
endif()

if("z-vcpkg-make-get-configure-triplets" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_get_configure_triplets.cmake")
endif()

if("z-vcpkg-make-get-crosscompiling" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_get_crosscompiling.cmake")
endif()

unit_test_report_result()
