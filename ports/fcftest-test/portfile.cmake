vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.6"
    SHA512 c683da73a48eb79da8851f2545e9dbca6b52e99206871caeaf8fd59b260a44885843c76ab49f07b21bd751ab9ec15828a894ce044d2393b04999b08247d9cb92
)

# PATCH: Remove the legacy local include path and inject vcpkg package discovery
set(TEST_CMAKE_FILE "${SOURCE_PATH}/test/CMakeLists.txt")
file(READ "${TEST_CMAKE_FILE}" CMAKE_CONTENTS)

# Robustly remove target_include_directories using regex and append proper integration
string(REGEX REPLACE
    "target_include_directories\\s*\\(\\s*fcf-test-test[^\\)]*\\)"
    ""
    CMAKE_CONTENTS "${CMAKE_CONTENTS}"
)

# Append find_package and target_link_libraries to the end of the file
string(APPEND CMAKE_CONTENTS "\nfind_package(fcftest CONFIG REQUIRED)\ntarget_link_libraries(fcf-test-test PRIVATE fcf::fcfTest)\n")

file(WRITE "${TEST_CMAKE_FILE}" "${CMAKE_CONTENTS}")

# Configure the test directory
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/test"
)

# Build the test executable target
vcpkg_cmake_build(
    TARGET fcf-test-test
)

# Execute tests only if NOT cross-compiling
if(NOT VCPKG_CROSSCOMPILING)
    # Determine the executable suffix (.exe for Windows)
    set(EXECUTABLE_SUFFIX "")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(EXECUTABLE_SUFFIX ".exe")
    endif()

    # Locate the built test binary (Release or Debug configuration)
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/fcf-test-test${EXECUTABLE_SUFFIX}")
        set(TEST_EXE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    else()
        set(TEST_EXE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    endif()

    message(STATUS "Running fcfTest integration tests from: ${TEST_EXE_DIR}")

    # Execute the test binary
    vcpkg_execute_build_process(
        COMMAND "${TEST_EXE_DIR}/fcf-test-test${EXECUTABLE_SUFFIX}"
        WORKING_DIRECTORY "${TEST_EXE_DIR}"
        LOGNAME "test-run-${TARGET_TRIPLET}"
    )

    # Print test logs to the console for CI visibility
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/test-run-${TARGET_TRIPLET}-out.log")
        file(READ "${CURRENT_BUILDTREES_DIR}/test-run-${TARGET_TRIPLET}-out.log" TEST_OUTPUT_LOG)
        message(STATUS "=== INTEGRATION TESTS LOG OUTPUT BEGIN ===")
        message(STATUS "${TEST_OUTPUT_LOG}")
        message(STATUS "=== INTEGRATION TESTS LOG OUTPUT END ===")
    endif()
else()
    message(STATUS "Skipping integration tests execution due to cross-compilation target.")
endif()

# Tell vcpkg that it's intentional that this test-only port has an empty include folder
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Install the license file to the proper copyright location
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

