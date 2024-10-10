set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
include("${CMAKE_CURRENT_LIST_DIR}/../unit-test-cmake/portfile.cmake")

if("z-vcpkg-make-prepare-compile-flags" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_prepare_compile_flags.cmake")
endif()

if("z-vcpkg-make-determine-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_arch.cmake")
endif()

if("z-vcpkg-make-determine-host-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_host_arch.cmake")
endif()

if("z-vcpkg-make-determine-target-arch" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_determine_target_arch.cmake")
endif()

if("z-vcpkg-make-z-adapt-lib-link-names" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_adapt_lib_link_names.cmake")
endif()
