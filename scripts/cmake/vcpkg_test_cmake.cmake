## # vcpkg_test_cmake
##
## Tests a built package for CMake `find_package()` integration.
##
## ## Usage:
## ```cmake
## vcpkg_test_cmake(PACKAGE_NAME <name> [MODULE] [GENERATOR generator])
## ```
##
## ## Parameters:
##
## ### PACKAGE_NAME
## The expected name to find with `find_package()`.
##
## ### MODULE
## Indicates that the library expects to be found via built-in CMake targets.
##
## ### GENERATOR
## The cmake generator to use for the test. It not provided, fallback to the one used
## during a previous vcpkg_configure_cmake() call, or use CMake default generator.
##
function(vcpkg_test_cmake)
    cmake_parse_arguments(_tc "MODULE" "PACKAGE_NAME;GENERATOR" "" ${ARGN})

    if(NOT DEFINED _tc_PACKAGE_NAME)
      message(FATAL_ERROR "PACKAGE_NAME must be specified")
    endif()
    if(_tc_MODULE)
      set(PACKAGE_TYPE MODULE)
    else()
      set(PACKAGE_TYPE CONFIG)
    endif()

    if(_tc_GENERATOR)
      set(GENERATOR ${_tc_GENERATOR})
    else()
      # vcpkg_configure_cmake defines _VCPKG_CMAKE_GENERATOR when called
      set(GENERATOR ${_VCPKG_CMAKE_GENERATOR})
    endif()

    if(VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
      message(STATUS "Skipping CMake integration test due to v142 / CMake interaction issues")
      return()
    endif()

    message(STATUS "Performing CMake integration test")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)

    # Generate test source CMakeLists.txt
    set(VCPKG_TEST_CMAKELIST ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/CMakeLists.txt)
    file(WRITE  ${VCPKG_TEST_CMAKELIST} "cmake_minimum_required(VERSION 3.10)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "set(CMAKE_PREFIX_PATH \"${CURRENT_PACKAGES_DIR};${CURRENT_INSTALLED_DIR}\")\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)\n")

    if(GENERATOR)
      set(GENERATOR_ARGS "-G" "${GENERATOR}")
    endif()

    # Run cmake config with a generated CMakeLists.txt
    set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-cmake-${TARGET_TRIPLET}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} ${GENERATOR_ARGS} .
      OUTPUT_FILE "${LOGPREFIX}-out.log"
      ERROR_FILE "${LOGPREFIX}-err.log"
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test
    )
    if(error_code)
      message(FATAL_ERROR "CMake integration test failed; unable to find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)")
    endif()
endfunction()
