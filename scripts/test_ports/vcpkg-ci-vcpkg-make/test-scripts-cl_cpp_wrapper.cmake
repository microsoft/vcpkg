block()
set(SOURCE_PATH "${CURRENT_PORT_DIR}/test-cl_cpp_wrapper")
set(VCPKG_BUILD_TYPE release)

vcpkg_backup_env_variables(VARS CPP TEST_FLAGS)

# Test that that CPP processes stdin
# vcpkg_configure_make picks scripts/buildsystems/make_wrapper/cl_cpp_wrapper

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CPP} "cl_cpp_wrapper")
endif()

unit_test_ensure_fatal_error([[
    set(ENV{TEST_FLAGS} -DEXPECT_FAILURE)
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}" COPY_SOURCE USE_WRAPPERS)
]])

unit_test_ensure_success([[
    set(ENV{TEST_FLAGS} -DEXPECT_SUCCESS)
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}" COPY_SOURCE USE_WRAPPERS)
]])

vcpkg_restore_env_variables(VARS CPP TEST_FLAGS)
endblock()
