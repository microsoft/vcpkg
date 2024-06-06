set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if("z-vcpkg-make-prepare-compile-flags" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_make_prepare_compile_flags.cmake")
endif()

