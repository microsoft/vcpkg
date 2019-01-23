include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tensorflow/tensorflow
    REF v1.12.0
    SHA512 b145a9118856aa00a829ab6af89bff4e1e131371c96d77b07532544112803c4574d97ef224b28a64437a2af8db4286786dc0b4123efe110b2aa734b443a7e238
)

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

vcpkg_execute_required_process(
    COMMAND patch -Np1 -i ${CMAKE_CURRENT_LIST_DIR}/patches/5b14577d42842871f1cb0eb8dfe77d32db1eb654.patch
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
# https://github.com/tensorflow/tensorflow/issues/20950
vcpkg_execute_required_process(
    COMMAND patch -Np1 -i ${CMAKE_CURRENT_LIST_DIR}/patches/protobuf-version-bump.patch
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
vcpkg_execute_required_process(
    COMMAND patch -Np1 -i ${CMAKE_CURRENT_LIST_DIR}/patches/protobuf-python37-apply.patch
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
# https://github.com/protocolbuffers/protobuf/issues/4086
vcpkg_execute_required_process(
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/patches/protobuf-python37.patch third_party/
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
# https://github.com/tensorflow/tensorflow/issues/23402
vcpkg_execute_required_process(
    COMMAND patch -Np1 -i ${CMAKE_CURRENT_LIST_DIR}/patches/explicitly_import_bazelrc.patch
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)

vcpkg_execute_required_process(
    COMMAND env; echo ${CURRENT_PACKAGES_DIR}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)

vcpkg_execute_required_process(
    COMMAND sh "${CMAKE_CURRENT_LIST_DIR}/build_tensorflow.sh" "${CURRENT_PACKAGES_DIR}"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc RENAME copyright)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/TensorflowCCConfig.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
