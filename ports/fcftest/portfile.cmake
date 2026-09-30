vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.7"
    SHA512 fbba290c47ce80865404bfde2740c08e97e6683cf6da4edc3d9ac075a99f5434d748f3cc0db5d96689af32194de0dc8246918b981bd9541c05722cc1fc259364
)

file(INSTALL "${SOURCE_PATH}/test.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fcfTest")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/test"
    OPTIONS
        "-DCMAKE_INCLUDE_PATH=${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_cmake_build(
    TARGET fcf-test-test
)

if(NOT VCPKG_CROSSCOMPILING)
    set(EXECUTABLE_SUFFIX "")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(EXECUTABLE_SUFFIX ".exe")
    endif()

    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/fcf-test-test${EXECUTABLE_SUFFIX}")
        set(TEST_EXE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    else()
        set(TEST_EXE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    endif()

    message(STATUS "Running internal fcfTest tests from: ${TEST_EXE_DIR}")
    vcpkg_execute_build_process(
        COMMAND "${TEST_EXE_DIR}/fcf-test-test${EXECUTABLE_SUFFIX}"
        WORKING_DIRECTORY "${TEST_EXE_DIR}"
        LOGNAME "test-run-${TARGET_TRIPLET}"
    )

    if(EXISTS "${CURRENT_BUILDTREES_DIR}/test-run-${TARGET_TRIPLET}-out.log")
        file(READ "${CURRENT_BUILDTREES_DIR}/test-run-${TARGET_TRIPLET}-out.log" TEST_OUTPUT_LOG)
        message(STATUS "=== INTERNAL TESTS LOG OUTPUT BEGIN ===")
        message(STATUS "${TEST_OUTPUT_LOG}")
        message(STATUS "=== INTERNAL TESTS LOG OUTPUT END ===")
    endif()
else()
    message(STATUS "Skipping internal tests execution due to cross-architecture target (Target: ${VCPKG_TARGET_ARCHITECTURE}, Host: ${VCPKG_HOST_ARCHITECTURE})")
endif()


file(WRITE "${CURRENT_PACKAGES_DIR}/share/fcftest/fcftestConfig.cmake" "
  if(NOT TARGET fcf::fcftest)
    add_library(fcf::fcftest INTERFACE IMPORTED)
    set_target_properties(fcf::fcftest PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
    )
  endif()
")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

