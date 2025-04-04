set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# For simplicity and speed, reusing source and build dirs
# - and the CMake cache - in multiple steps.
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/project")
file(REMOVE_RECURSE "${SOURCE_PATH}")


message(STATUS "Testing toolchain find_library search path setup")

file(COPY "${CURRENT_PORT_DIR}/project/" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE  # keep separate logs
)
vcpkg_cmake_build()


message(STATUS "Testing toolchain capability VCPKG_LOCK_FIND_PACKAGE")

set(VCPKG_BUILD_TYPE release)

function(write_test_project TEST_CODE)
    configure_file("${CURRENT_PORT_DIR}/project/vcpkg_lock_find_package/CMakeLists.txt.in" "${SOURCE_PATH}/CMakeLists.txt" @ONLY)
endfunction()

include("${CURRENT_HOST_INSTALLED_DIR}/share/unit-test-cmake/test-macros.cmake")

function(send_error summary)
    set_has_error()
    string(SHA1 id "${summary}")
    string(SUBSTRING "${id}" 0 6 id)
    set(log_base "${CURRENT_BUILDTREES_DIR}/test-${TARGET_TRIPLET}-${id}")
    set(log_files "")
    file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-out.log" "${log_base}-out.log")
    file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-rel-err.log" "${log_base}-err.log")
    message(SEND_ERROR "  Test failed:\n${summary}\n  See logs for more information:\n    ${log_base}-out.log\n    ${log_base}-err.log\n")
endfunction()

macro(unit_test_ensure_cmake_success utecs_test)
    write_test_project("${utecs_test}")
    cmake_language(EVAL CODE "vcpkg_cmake_build()")
    if(Z_VCPKG_UNIT_TEST_HAS_FATAL_ERROR)
        send_error("${utecs_test}  was expected to be successful.")
    endif()
    unset_fatal_error()
endmacro()

macro(unit_test_ensure_cmake_error utece_test)
    write_test_project("${utece_test}")
    cmake_language(EVAL CODE "vcpkg_cmake_build()")
    if(NOT Z_VCPKG_UNIT_TEST_HAS_FATAL_ERROR)
        send_error("${utece_test} was expected to be successful.")
    endif()
    unset_fatal_error()
endmacro()


unit_test_ensure_cmake_error([[
    # No VCPKG_LOCK_FIND_PACKAGE
    find_package(absentPackageX REQUIRED)
]])
unit_test_ensure_cmake_success([[
    # No VCPKG_LOCK_FIND_PACKAGE
    find_package(directPackageX REQUIRED)
    find_package(transitivePackageX REQUIRED)
    find_package(transitiveOptionalAbsentPackageX REQUIRED)
    find_package(absentPackageX)
    if(absentPackageX_FOUND)
        message(FATAL_ERROR "absentPackageX_FOUND unexpectedly set to '${absentPackageX_FOUND}'.")
    endif()
]])


unit_test_ensure_cmake_success([[
    # Disabling an absent optional package
    set(VCPKG_LOCK_FIND_PACKAGE_absentPackageX 0)
    find_package(absentPackageX)
]])

unit_test_ensure_cmake_error([[
    # Disabling an absent required package
    set(VCPKG_LOCK_FIND_PACKAGE_absentPackageX 0)
    find_package(absentPackageX REQUIRED)
]])

unit_test_ensure_cmake_success([[
    # Disabling an available optional package
    set(VCPKG_LOCK_FIND_PACKAGE_directPackageX 0)
    find_package(directPackageX)
    if(directPackageX_FOUND)
        message(FATAL_ERROR "directPackageX_FOUND unexpectedly set to '${directPackageX_FOUND}'.")
    endif()
]])

unit_test_ensure_cmake_error([[
    # Disabling an available required package
    set(VCPKG_LOCK_FIND_PACKAGE_directPackageX 0)
    find_package(directPackageX REQUIRED)
]])

unit_test_ensure_cmake_success([[
    # Core capability: a smart CMAKE_DISABLE_FIND_PACKAGE_<Pkg>
    # Disabling only the direct package
    set(VCPKG_LOCK_FIND_PACKAGE_directPackageX 0)
    find_package(directPackageX) # optional
    find_package(transitivePackageX REQUIRED)
]])

unit_test_ensure_cmake_error([[
    # For reference: CMake default behavior which we want to avoid
    set(CMAKE_DISABLE_FIND_PACKAGE_directPackageX 1)
    find_package(transitivePackageX REQUIRED)
]])


unit_test_ensure_cmake_error([[
    # Requiring an absent optional package
    set(VCPKG_LOCK_FIND_PACKAGE_absentPackageX 1)
    find_package(absentPackageX)
]])

unit_test_ensure_cmake_error([[
    # Requiring an absent required package
    set(VCPKG_LOCK_FIND_PACKAGE_absentPackageX 1)
    find_package(absentPackageX REQUIRED)
]])

unit_test_ensure_cmake_success([[
    # Requiring an available optional package
    set(VCPKG_LOCK_FIND_PACKAGE_directPackageX 1)
    find_package(directPackageX)
    if(NOT DEFINED directPackageX_FOUND)
        message(FATAL_ERROR "directPackageX_FOUND unexpectedly undefined.")
    elseif(NOT directPackageX_FOUND)
        message(FATAL_ERROR "directPackageX_FOUND unexpectedly set to '${directPackageX_FOUND}'.")
    endif()
]])

unit_test_ensure_cmake_success([[
    # Requiring an available required package
    set(VCPKG_LOCK_FIND_PACKAGE_directPackageX 1)
    find_package(directPackageX REQUIRED)
    if(NOT DEFINED directPackageX_FOUND)
        message(FATAL_ERROR "directPackageX_FOUND unexpectedly undefined.")
    elseif(NOT directPackageX_FOUND)
        message(FATAL_ERROR "directPackageX_FOUND unexpectedly set to '${directPackageX_FOUND}'.")
    endif()
]])

unit_test_ensure_cmake_success([[
    # Core capability: a smart CMAKE_REQUIRE_FIND_PACKAGE_<Pkg>
    # Requiring only the direct package
    set(VCPKG_LOCK_FIND_PACKAGE_absentPackageX 1)
    find_package(transitiveOptionalAbsentPackageX REQUIRED)
]])

unit_test_ensure_cmake_error([[
    # For reference: CMake default behavior which we want to avoid
    set(CMAKE_REQUIRE_FIND_PACKAGE_absentPackageX 1)
    find_package(transitiveOptionalAbsentPackageX REQUIRED)
]])

unit_test_report_result()
