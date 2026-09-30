vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.6"
    SHA512 c683da73a48eb79da8851f2545e9dbca6b52e99206871caeaf8fd59b260a44885843c76ab49f07b21bd751ab9ec15828a894ce044d2393b04999b08247d9cb92
)

file(INSTALL "${SOURCE_PATH}/test.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fcfTest")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/test"
    OPTIONS
        "-DCMAKE_CXX_FLAGS=-I${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_cmake_build(
    TARGET fcf-test-test
)

if(NOT VCPKG_TARGET_IS_ANDROID AND NOT VCPKG_TARGET_IS_IOS AND VCPKG_TARGET_ARCHITECTURE STREQUAL VCPKG_HOST_ARCHITECTURE)
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

