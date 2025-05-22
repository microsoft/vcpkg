set(host "<unknown>")
set(target "<unknown>")
set(systems ANDROID LINUX OSX UWP WINDOWS)
foreach(system IN LISTS systems)
    if(VCPKG_HOST_IS_${system})
        set(host "${system}")
    endif()
    if(VCPKG_TARGET_IS_${system})
        set(target "${system}")
    endif()
endforeach()
if(VCPKG_MAKE_BUILD_TRIPLET)
    set(result "VCPKG_MAKE_BUILD_TRIPLET is '${VCPKG_MAKE_BUILD_TRIPLET}'")
else()
    z_vcpkg_make_get_configure_triplets(triplets COMPILER_NAME "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    set(result "result is '${triplets}'")
endif()
message(STATUS "
VCPKG_HOST_IS_${host}
  VCPKG_TARGET_IS_${target}
    ${result}
")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
include("${CURRENT_HOST_INSTALLED_DIR}/share/unit-test-cmake/test-macros.cmake")

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

if("z-vcpkg-make-z-adapt-lib-link-names" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_adapt_lib_link_names.cmake")
endif()

if("z-vcpkg-make-get-configure-triplets" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_get_configure_triplets.cmake")
endif()

unit_test_report_result()
