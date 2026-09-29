vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.5"
    SHA512 c37e2dc7c2867e1d8d30f9b623c80c64476c7c26bbe0b0d82cfc140fcec9406549406843c73f7337786dc2f78ad59c7f8b8a15c18bbea8ff1329649b33bf192f
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

message(STATUS "Running internal fcfTest tests...")
vcpkg_execute_build_process(
    COMMAND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/fcf-test-test"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "test-run-${TARGET_TRIPLET}-dbg"
)

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

