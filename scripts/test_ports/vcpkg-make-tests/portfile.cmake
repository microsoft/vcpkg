set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if("z_vcpkg_make_prepare_compile_flags" IN_LIST FEATURES)
    message(FATAL_ERROR "Known False Assertion Failed.")
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_prepare_compile_flags.cmake")
endif()

