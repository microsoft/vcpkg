include(vcpkg_common_functions)

message(WARNING "This tensorflow port currently is experimental on Windows and Linux platforms.")

if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "TensorFlow does not support 32bit system.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tensorflow/tensorflow
    REF v1.14.0
    SHA512 ac9ea5a2d1c761aaafbdc335259e29c128127b8d069ec5b206067935180490aa95e93c7e13de57f7f54ce4ba4f34a822face22b4a028f60185edb380e5cd4787
    HEAD_REF master
    PATCHES
        file-exists.patch # required or otherwise it cant find python lib path on windows
        fix-build-error.patch # Fix namespace error
)

# due to https://github.com/bazelbuild/bazel/issues/8028, bazel must be version 25.0 or higher
vcpkg_find_acquire_program(BAZEL)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${BAZEL_DIR})
set(ENV{BAZEL_BIN_PATH} "${BAZEL}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})
set(ENV{PYTHON_BIN_PATH} "${PYTHON3}")

function(tensorflow_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

# we currently only support the release version
tensorflow_try_remove_recurse_wait(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(GLOB SOURCES ${SOURCE_PATH}/*)
file(COPY ${SOURCES} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES unzip patch diffutils git)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
    set(ENV{BAZEL_SH} ${MSYS_ROOT}/usr/bin/bash.exe)

    set(ENV{BAZEL_VS} $ENV{VSInstallDir})
    set(ENV{BAZEL_VC} $ENV{VCInstallDir})
endif()

# tensorflow has long file names, which will not work on windows
set(ENV{TEST_TMPDIR} ${CURRENT_BUILDTREES_DIR}/../.bzl)

set(ENV{USE_DEFAULT_PYTHON_LIB_PATH} 1)
set(ENV{TF_NEED_KAFKA} 0)
set(ENV{TF_NEED_OPENCL_SYCL} 0)
set(ENV{TF_NEED_AWS} 0)
set(ENV{TF_NEED_GCP} 0)
set(ENV{TF_NEED_HDFS} 0)
set(ENV{TF_NEED_S3} 0)
set(ENV{TF_ENABLE_XLA} 0)
set(ENV{TF_NEED_GDR} 0)
set(ENV{TF_NEED_VERBS} 0)
set(ENV{TF_NEED_OPENCL} 0)
set(ENV{TF_NEED_MPI} 0)
set(ENV{TF_NEED_TENSORRT} 0)
set(ENV{TF_NEED_NGRAPH} 0)
set(ENV{TF_NEED_IGNITE} 0)
set(ENV{TF_NEED_ROCM} 0)
set(ENV{TF_SET_ANDROID_WORKSPACE} 0)
set(ENV{TF_DOWNLOAD_CLANG} 0)
set(ENV{TF_NCCL_VERSION} 2.3)
set(ENV{NCCL_INSTALL_PATH} "")
set(ENV{CC_OPT_FLAGS} "/arch:AVX")
set(ENV{TF_NEED_CUDA} 0)

message(STATUS "Configuring TensorFlow")

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${SOURCE_PATH}/configure.py
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME config-${TARGET_TRIPLET}-rel
)
message(STATUS "Warning: Building TensorFlow can take an hour or more.")

if(CMAKE_HOST_WIN32)
    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "${BAZEL} build --verbose_failures -c opt --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true ///tensorflow:libtensorflow_cc.so ///tensorflow:install_headers"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
else()
    vcpkg_execute_build_process(
        COMMAND ${BAZEL} build --verbose_failures -c opt --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true //tensorflow:libtensorflow_cc.so //tensorflow:install_headers
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
endif()

file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-genfiles/tensorflow/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/tensorflow-external)

if(CMAKE_HOST_WIN32)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0.if.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0.if.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
else()
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_framework.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/libtensorflow_framework.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/LICENSE ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/TensorflowCCConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc/TensorflowCCConfig.cmake ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc/unofficial-tensorflow-cc-config.cmake)