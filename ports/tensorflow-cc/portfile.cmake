include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "This tensorflow port currently only supports building for Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tensorflow/tensorflow
    REF v1.12.0
    SHA512 b145a9118856aa00a829ab6af89bff4e1e131371c96d77b07532544112803c4574d97ef224b28a64437a2af8db4286786dc0b4123efe110b2aa734b443a7e238
    HEAD_REF master
    PATCHES
        patches/5b14577d42842871f1cb0eb8dfe77d32db1eb654.patch
        # https://github.com/tensorflow/tensorflow/issues/20950
        patches/protobuf-version-bump.patch
        patches/protobuf-python37-apply.patch
        # https://github.com/tensorflow/tensorflow/issues/23402
        patches/explicitly_import_bazelrc.patch
)

# https://github.com/protocolbuffers/protobuf/issues/4086
file(COPY ${CMAKE_CURRENT_LIST_DIR}/patches/protobuf-python37.patch DESTINATION ${SOURCE_PATH}/third_party)

vcpkg_find_acquire_program(BAZEL)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${BAZEL_DIR})

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    message(FATAL_ERROR "Failed to remove ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
endif()
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(GLOB SOURCES ${SOURCE_PATH}/*)
file(COPY ${SOURCES} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

set(ENV{PYTHON_BIN_PATH} "${PYTHON3}")
set(ENV{TEST_TMPDIR} ${CURRENT_BUILDTREES_DIR}/bazel)
set(ENV{CURRENT_PACKAGES_DIR} ${CURRENT_PACKAGES_DIR})

message(STATUS "Warning: Building tensorflow can take an hour or more.")
vcpkg_execute_required_process(
    COMMAND sh "${CMAKE_CURRENT_LIST_DIR}/build_tensorflow.sh"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc
    RENAME copyright
)

file(INSTALL
    ${CMAKE_CURRENT_LIST_DIR}/TensorflowCCConfig.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc
    RENAME unofficial-tensorflow-cc-config.cmake
)
