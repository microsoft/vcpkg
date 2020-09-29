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
  cmake_parse_arguments(_tc "MODULE" "PACKAGE_NAME;VER;HEADER;FUNC" "TARGETS;LIBRARIES;INCLUDES" ${ARGN})
  
  get_filename_component(VCPKG_ROOT "${CURRENT_PORT_DIR}" PATH)
  get_filename_component(VCPKG_ROOT "${VCPKG_ROOT}" PATH)

  if(NOT DEFINED _tc_PACKAGE_NAME)
    message(FATAL_ERROR "PACKAGE_NAME must be specified")
  endif()
  if(NOT DEFINED _tc_HEADER)
    message(FATAL_ERROR "HEADER must be specified")
  endif()
  if(NOT DEFINED _tc_FUNC)
    message(FATAL_ERROR "FUNC must be specified")
  endif()
  if(_tc_MODULE)
    set(PACKAGE_TYPE MODULE)
  else()
    set(PACKAGE_TYPE CONFIG)
  endif()
  
  if (NOT DEFINED _tc_LIBRARIES AND NOT DEFINED _tc_TARGETS)
    message(FATAL_ERROR "TARGETS and LIBRARIES must declare one of them!")
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
  file(APPEND  ${VCPKG_TEST_CMAKELIST} "set(CMAKE_TOOLCHAIN_FILE \"${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake\")\n")
  file(APPEND  ${VCPKG_TEST_CMAKELIST} "project(vcpkg_test CXX)\n")
  file(APPEND ${VCPKG_TEST_CMAKELIST} "\n")
  file(APPEND  ${VCPKG_TEST_CMAKELIST} "add_executable(vcpkg_test vcpkg_test.cpp)\n")
  file(APPEND ${VCPKG_TEST_CMAKELIST} "find_package(${_tc_PACKAGE_NAME} ${_tc_VER} ${PACKAGE_TYPE} REQUIRED)\n")
  if (_tc_TARGETS)
    file(APPEND ${VCPKG_TEST_CMAKELIST} "target_link_libraries(vcpkg_test PRIVATE ${_tc_TARGETS})\n")
  endif()
  if (_tc_LIBRARIES)
    file(APPEND ${VCPKG_TEST_CMAKELIST} "target_link_libraries(vcpkg_test PRIVATE \${${_tc_LIBRARIES}})\n")
  endif()
  if (_tc_INCLUDES)
    file(APPEND ${VCPKG_TEST_CMAKELIST} "target_include_directories(vcpkg_test PRIVATE ${_tc_INCLUDES})\n")
  endif()
  
  set(VCPKG_TEST_CODE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/vcpkg_test.cpp)
  file(WRITE ${VCPKG_TEST_CODE} "#include <${_tc_HEADER}>\n")
  file(APPEND  ${VCPKG_TEST_CODE} "#ifdef __cplusplus\n")
  file(APPEND ${VCPKG_TEST_CODE} "extern \"C\"\n")
  file(APPEND ${VCPKG_TEST_CODE} "#endif\n")
  file(APPEND ${VCPKG_TEST_CODE} "char ${_tc_FUNC}();\n")
  file(APPEND ${VCPKG_TEST_CODE} "int main()\n")
  file(APPEND ${VCPKG_TEST_CODE} "{\n")
  file(APPEND ${VCPKG_TEST_CODE} "return ${_tc_FUNC};\n")
  file(APPEND ${VCPKG_TEST_CODE} "}\n")
  #To properly test if the package is actually working haveway correctly we have to link all targets of a package to 
  #a test executable and than actually build it. This will not discover if every symbol exported by the library is available/linked
  #but it will doscover if all files which are linked by a target actual exist. Problem is: How to discover all targets?
#    file(APPEND ${VCPKG_TEST_CMAKELIST} "add_executable(${_tc_PACKAGE_NAME}_exe ${VCPKG_TEST_SOURCE})\n")
#    file(APPEND ${VCPKG_TEST_CMAKELIST} "target_link_libraries(${_tc_PACKAGE_NAME}_exe PRIVATE ${_tc_PACKAGE_NAME})\n")

  if (0)
    set(VCPKG_CMAKE_TEST_GENERATOR "Visual Studio 15 2017")
    if (BUILD_ARCH STREQUAL Win32)
      set(TEST_ARCH_OPT -A x86)
    elseif (BUILD_ARCH STREQUAL x64)
      set(TEST_ARCH_OPT -A x64)
    endif()
  else()
    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    vcpkg_add_to_path(${NINJA_PATH})
    set(VCPKG_CMAKE_TEST_GENERATOR Ninja)
  endif()
  

  # Run cmake config with a generated CMakeLists.txt
  message("cmd: ${CMAKE_COMMAND} -G \"${VCPKG_CMAKE_TEST_GENERATOR}\" .")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -G "${VCPKG_CMAKE_TEST_GENERATOR}" . -DCMAKE_BUILD_TYPE=Debug ${TEST_ARCH_OPT} -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}
    OUTPUT_FILE "${PORT}-${TARGET_TRIPLET}-test-out.log"
    ERROR_FILE "${PORT}-${TARGET_TRIPLET}-test-err.log"
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test
  )
  if(error_code)
    message(FATAL_ERROR "CMake integration test failed; unable to find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)")
  endif()
endfunction()
