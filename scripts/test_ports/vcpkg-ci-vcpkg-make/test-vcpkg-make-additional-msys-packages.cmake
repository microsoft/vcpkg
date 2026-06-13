block()

# 1. Mock vcpkg_insert_msys_into_path to capture packages
function(vcpkg_insert_msys_into_path msys_out)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "PATH_OUT"
        "PACKAGES;DIRECT_PACKAGES"
    )
    set_property(GLOBAL PROPERTY test_captured_msys_packages "${arg_PACKAGES}")
    set_property(GLOBAL PROPERTY test_captured_direct_packages "${arg_DIRECT_PACKAGES}")
    set("${msys_out}" "/mock/msys" PARENT_SCOPE)
endfunction()

# Reset the global properties
set_property(GLOBAL PROPERTY test_captured_msys_packages "")
set_property(GLOBAL PROPERTY test_captured_direct_packages "")
set_property(GLOBAL PROPERTY z_vcpkg_global_property_make_additional_msys_packages "")
set_property(GLOBAL PROPERTY z_vcpkg_global_property_make_direct_msys_packages "")

# Mock find_program to avoid file system and execution dependencies
function(find_program var)
    if("${var}" STREQUAL "PKGCONFIG")
        set("${var}" "/mock/pkgconfig" PARENT_SCOPE)
    elseif("${var}" STREQUAL "shell_cmd")
        set("${var}" "/mock/msys/usr/bin/bash.exe" PARENT_SCOPE)
    elseif("${var}" STREQUAL "Z_VCPKG_MAKE")
        set("${var}" "/mock/make" PARENT_SCOPE)
    endif()
endfunction()

# Test vcpkg_make_setup_win_msys directly
vcpkg_make_setup_win_msys(msys_root ADDITIONAL_MSYS_PACKAGES pkg1 pkg2 DIRECT_PACKAGES "http://url1" "sha1" "http://url2" "sha2")

get_property(captured_packages GLOBAL PROPERTY test_captured_msys_packages)
unit_test_check_variable_equal([[]] captured_packages "autoconf-wrapper;automake-wrapper;autoconf-archive;binutils;libtool;make;which;pkg1;pkg2")

get_property(captured_direct GLOBAL PROPERTY test_captured_direct_packages)
unit_test_check_variable_equal([[]] captured_direct "http://url1;sha1;http://url2;sha2")

# Test vcpkg_make_get_shell with CMAKE_HOST_WIN32 simulated
vcpkg_backup_env_variables(VARS PATH)
set(CMAKE_HOST_WIN32 TRUE)
set(VCPKG_MAKE_ACQUIRE_MSYS TRUE)

# Reset captured packages
set_property(GLOBAL PROPERTY test_captured_msys_packages "")
set_property(GLOBAL PROPERTY test_captured_direct_packages "")

# Set the global property of additional packages (simulating what vcpkg_make_configure/install does)
z_vcpkg_set_global_property(make_additional_msys_packages "pkgA;pkgB")
z_vcpkg_set_global_property(make_direct_msys_packages "http://urlA;shaA")

vcpkg_make_get_shell(shell_var)

get_property(captured_packages_shell GLOBAL PROPERTY test_captured_msys_packages)
unit_test_check_variable_equal([[]] captured_packages_shell "autoconf-wrapper;automake-wrapper;autoconf-archive;binutils;libtool;make;which;pkgA;pkgB")

get_property(captured_direct_shell GLOBAL PROPERTY test_captured_direct_packages)
unit_test_check_variable_equal([[]] captured_direct_shell "http://urlA;shaA")

unit_test_check_variable_equal([[]] shell_var "/mock/msys/usr/bin/bash.exe;--noprofile;--norc;--debug")

# Test vcpkg_make_configure parsing of ADDITIONAL_MSYS_PACKAGES and DIRECT_PACKAGES
# Let's mock side effects of vcpkg_make_configure
macro(z_vcpkg_warn_path_with_spaces)
endmacro()
macro(z_vcpkg_make_get_cmake_vars)
endmacro()
macro(z_vcpkg_make_prepare_flags)
endmacro()
macro(z_vcpkg_make_get_configure_triplets)
endmacro()
macro(z_vcpkg_make_set_common_vars)
endmacro()
macro(z_vcpkg_make_prepare_programs)
endmacro()
macro(vcpkg_make_run_configure)
endmacro()

# Set variables that the loops need
set(buildtypes "release")
set(suffix_RELEASE "rel")
set(path_suffix_RELEASE "")
set(workdir_RELEASE "${CURRENT_BUILDTREES_DIR}/mock-additional-msys-packages-test-dir")

z_vcpkg_set_global_property(make_additional_msys_packages "")
z_vcpkg_set_global_property(make_direct_msys_packages "")

vcpkg_make_configure(
    SOURCE_PATH "/mock/src"
    ADDITIONAL_MSYS_PACKAGES pkgX pkgY
    DIRECT_PACKAGES "http://urlX" "shaX"
)

z_vcpkg_get_global_property(actual_additional "make_additional_msys_packages")
unit_test_check_variable_equal([[]] actual_additional "pkgX;pkgY")

z_vcpkg_get_global_property(actual_direct "make_direct_msys_packages")
unit_test_check_variable_equal([[]] actual_direct "http://urlX;shaX")

# Test appending in vcpkg_make_install
# Mock side effects of vcpkg_make_install
macro(z_vcpkg_make_prepare_env)
endmacro()

function(vcpkg_run_shell_as_build)
    cmake_parse_arguments(PARSE_ARGV 0 mock_arg "" "LOGNAME" "")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/${mock_arg_LOGNAME}-out.log" "")
endfunction()

set(VCPKG_MAKE_TRACE_OPTIONS "--trace")

vcpkg_make_install(
    ADDITIONAL_MSYS_PACKAGES pkgY pkgZ
    DIRECT_PACKAGES "http://urlY" "shaY"
)

z_vcpkg_get_global_property(actual_additional_after_install "make_additional_msys_packages")
unit_test_check_variable_equal([[]] actual_additional_after_install "pkgX;pkgY;pkgZ")

z_vcpkg_get_global_property(actual_direct_after_install "make_direct_msys_packages")
unit_test_check_variable_equal([[]] actual_direct_after_install "http://urlX;shaX;http://urlY;shaY")

vcpkg_restore_env_variables(VARS PATH)
endblock()
