set(test_installed_dir "${CMAKE_CURRENT_BINARY_DIR}/vcpkg configure make installed")
file(MAKE_DIRECTORY "${test_installed_dir}/lib/manual-link" "${test_installed_dir}/debug/lib/manual-link")

set(CURRENT_INSTALLED_DIR "${test_installed_dir}")
z_vcpkg_configure_make_common_definitions()

set(VCPKG_TARGET_IS_WINDOWS TRUE)
set(VCPKG_DETECTED_CMAKE_LINKER "C:/toolchain/link.exe")
set(VCPKG_DETECTED_CMAKE_C_COMPILER "C:/toolchain/cl.exe")
set(VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_DEBUG "-debug -INCREMENTAL")
set(VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_DEBUG "")
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(arg_USE_WRAPPERS TRUE)
z_vcpkg_configure_make_process_flags(DEBUG)

set(expected_msvc_ldflags "-Xlinker -Xlinker -Xlinker -debug -Xlinker -Xlinker -Xlinker -INCREMENTAL")
unit_test_check_variable_equal([[]] LDFLAGS_DEBUG "${expected_msvc_ldflags}")

set(VCPKG_DETECTED_CMAKE_LINKER "C:/toolchain/ld.exe")
set(VCPKG_DETECTED_CMAKE_C_COMPILER "C:/toolchain/gcc.exe")
z_vcpkg_configure_make_process_flags(DEBUG)

set(expected_gnu_ldflags "-L${current_installed_dir_escaped}/debug/lib -L${current_installed_dir_escaped}/debug/lib/manual-link -debug -INCREMENTAL")
unit_test_check_variable_equal([[]] LDFLAGS_DEBUG "${expected_gnu_ldflags}")

file(REMOVE_RECURSE "${test_installed_dir}")
