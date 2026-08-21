set(VCPKG_POLICY_SKIP_ALL_POST_BUILD_CHECKS enabled)

if(VCPKG_CROSSCOMPILING)
    set(run_test OFF)
else()
    set(run_test ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS "-DVCPKG_CI_RUN_TEST=${run_test}"
)
vcpkg_cmake_install()
