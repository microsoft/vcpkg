## # vcpkg_test_cmake
##
## Tests a built package for CMake `find_package()` integration.
##
## ## Usage:
## ```cmake
## vcpkg_test_cmake(PACKAGE_NAME <name> [MODULE])
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
function(vcpkg_test_cmake)
    cmake_parse_arguments(_tc "MODULE" "PACKAGE_NAME" "" ${ARGN})

    if(NOT DEFINED _tc_PACKAGE_NAME)
      message(FATAL_ERROR "PACKAGE_NAME must be specified")
    endif()
    if(_tc_MODULE)
      set(PACKAGE_TYPE MODULE)
    else()
      set(PACKAGE_TYPE CONFIG)
    endif()

    if(VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
      message(STATUS "Skipping CMake integration test due to v142 / CMake interaction issues")
      return()
    endif()

    message(STATUS "Performing CMake integration test")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)

    #Generate Dummy source
#    set(VCPKG_TEST_SOURCE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/CMakeIntegration.cpp)
#    file(WRITE  ${VCPKG_TEST_SOURCE} "int main() \{\n")
#    file(APPEND ${VCPKG_TEST_SOURCE} "return 0;}")
    # Generate test source CMakeLists.txt
    set(VCPKG_TEST_CMAKELIST ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/CMakeLists.txt)
    file(WRITE  ${VCPKG_TEST_CMAKELIST} "cmake_minimum_required(VERSION 3.10)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "set(CMAKE_PREFIX_PATH \"${CURRENT_PACKAGES_DIR};${CURRENT_INSTALLED_DIR}\")\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)\n")
    #To properly test if the package is actually working haveway correctly we have to link all targets of a package to 
    #a test executable and than actually build it. This will not discover if every symbol exported by the library is available/linked
    #but it will doscover if all files which are linked by a target actual exist. Problem is: How to discover all targets?
#    file(APPEND ${VCPKG_TEST_CMAKELIST} "add_executable(${_tc_PACKAGE_NAME}_exe ${VCPKG_TEST_SOURCE})\n")
#    file(APPEND ${VCPKG_TEST_CMAKELIST} "target_link_libraries(${_tc_PACKAGE_NAME}_exe PRIVATE ${_tc_PACKAGE_NAME})\n")

    if(DEFINED _VCPKG_CMAKE_GENERATOR)
        set(VCPKG_CMAKE_TEST_GENERATOR "${_VCPKG_CMAKE_GENERATOR}")
    else()
        set(VCPKG_CMAKE_TEST_GENERATOR Ninja)
    endif()

    # Run cmake config with a generated CMakeLists.txt
    set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-cmake-${TARGET_TRIPLET}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -G ${VCPKG_CMAKE_TEST_GENERATOR} .
      OUTPUT_FILE "${LOGPREFIX}-out.log"
      ERROR_FILE "${LOGPREFIX}-err.log"
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test
    )
    if(error_code)
      message(FATAL_ERROR "CMake integration test failed; unable to find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)")
    endif()
endfunction()
