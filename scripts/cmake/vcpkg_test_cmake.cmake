## # vcpkg_test_cmake
##
## Post-built cmake test for port package.
##
## ## Usage:
## ```cmake
## vcpkg_test_cmake(PACKAGE_NAME <name>)
## ```
##
## Test a built package whether it can be found from other CMake project
## using find_package() cmake directive.
##
## ## Parameters:
##
## ## PACKAGE_NAME
## a name to put it as argument for find_package(<name>)
## Default is an upper case of ${PORT}
##
## ## Notes:
## This command should be called at an end of portfile.cmake. 
##
function(vcpkg_test_cmake)
    # Parse arguments
    cmake_parse_arguments(_tc "" "PACKAGE_NAME" "" ${ARGN})
    string(TOUPPER ${PORT} TARGET_NAME)
    if(_tc_PACKAGE_NAME)
      set(TEST_TARGET_PACKAGE ${_tc_PACKAGE_NAME})
    else()
      set(TEST_TARGET_PACKAGE ${TARGET_NAME})
    endif()

    message(STATUS "Performing post-build test")
    # Generate test source CMakeLists.txt
    # check twice explicitly; first to find TARGET-config.cmake then using FindTARGET.cmake module.
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source)
    set(VCPKG_TEST_CMAKELIST ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg-test-source/CMakeLists.txt)
    file(WRITE  ${VCPKG_TEST_CMAKELIST} "cmake_minimum_required(VERSION 3.10)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "set(CMAKE_PREFIX_PATH \"${CURRENT_PACKAGES_DIR}\")\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "find_package(${TEST_TARGET_PACKAGE} CONFIG QUIET)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "if(NOT ${TARGET_NAME}_FOUND OR NOT ${TEST_TARGET_PACKAGE}_FOUND)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "  find_package(${TEST_TARGET_PACKAGE})\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "endif()\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "if(NOT ${TARGET_NAME}_FOUND OR NOT ${TEST_TARGET_PACKAGE}_FOUND)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "  message(FATAL_ERROR \"Fail to find ${TEST_TARGET_PACKAGE} by find_package() directive\")\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "endif()\n")
    # Run cmake config with a generated CMakeLists.txt
    set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-${TARGET_TRIPLET}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} ./vcpkg-test-source 
        OUTPUT_FILE "${LOGPREFIX}-out.log"
        ERROR_FILE "${LOGPREFIX}-err.log"
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)
    if(error_code)
      message(FATAL_ERROR "Post-build test failed")
    endif()
    message(STATUS "Performing post-build test done")
endfunction()