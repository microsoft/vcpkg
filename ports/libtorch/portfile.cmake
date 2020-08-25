set(LIBTORCH_VERSION 1.6.0)

if (NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    message(FATAL_ERROR "only x64 target supported")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda     USE_CUDA
)

if(${FEATURE_OPTIONS} MATCHES "USE_CUDA=ON")
    set(DEVICE "cu102")
else()
    set(DEVICE "cpu")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    if(${FEATURE_OPTIONS} MATCHES "USE_CUDA=ON")
        vcpkg_download_distfile(ARCHIVE 
        URLS  "https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-${LIBTORCH_VERSION}.zip"
        FILENAME libtorch-${LIBTORCH_VERSION}-${DEVICE}.zip
        SHA512 eefc1a53b206a61555d15cd8a873e56fbc29d678f92a31d1c06aa50c2205825439c557c1f023fdca2dc2157340843ea022df932d8711b8ba80e2f7d69b45cb46)

        vcpkg_download_distfile(ARCHIVE_DEBUG
        URLS  "https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-debug-${LIBTORCH_VERSION}.zip"
        FILENAME libtorch-${LIBTORCH_VERSION}-${DEVICE}-debug.zip
        SHA512 4fcff984aa51761222b25630b8faff84f727727cd5032cfdae8e7cb33e6d56519316e823f3bcc8a4c4cdc7cc8713b606d2a2737a44e4eb14cdee97d4ed15f70a)
    
    else()
        vcpkg_download_distfile(ARCHIVE 
        URLS  "https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-${LIBTORCH_VERSION}%2B${DEVICE}.zip"
        FILENAME libtorch-${LIBTORCH_VERSION}-${DEVICE}.zip
        SHA512 44bddbd8194dd838ceb7ffa44b6e21d7fb8ad364bfb701d396af5cf3598fa1fb5182748e11f168e7025d38b182d027428130bae3462283787976a0eed2401c6c)

        vcpkg_download_distfile(ARCHIVE_DEBUG
        URLS  "https://download.pytorch.org/libtorch/${DEVICE}/libtorch-win-shared-with-deps-debug-${LIBTORCH_VERSION}%2B${DEVICE}.zip"
        FILENAME libtorch-${LIBTORCH_VERSION}-${DEVICE}-debug.zip
        SHA512 77853d9a6f07a3376168b9fc530b48b2b0346dac1f3c0a64d5480d12fae5f18db1b4730cbdffaeffb0dc03cf8c954727900fbacc5a615565f59ac3a32f244c39)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(${FEATURE_OPTIONS} MATCHES "USE_CUDA=ON")
        message(FATAL_ERROR "CUDA not supported on mac")
    endif()
    vcpkg_download_distfile(ARCHIVE 
    URLS  "https://download.pytorch.org/libtorch/cpu/libtorch-macos-${LIBTORCH_VERSION}.zip"
    FILENAME libtorch-${LIBTORCH_VERSION}.zip
    SHA512 c406c310ed3d3873a1c3bc70252e8d3dd8ab0b87e732e3829af89a4a2bb7a551642c9856f156ad32205f02ad46456be1cc3607c89ddf7ba5b12c603e39ebf1c5)
else()
    vcpkg_download_distfile(ARCHIVE 
    URLS  "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}.zip"
    FILENAME libtorch-${LIBTORCH_VERSION}.zip
    SHA512 0)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH 
    ARCHIVE ${ARCHIVE}
)
if(DEFINED ARCHIVE_DEBUG)
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH     DEBUG_SOURCE_PATH
        ARCHIVE             ${ARCHIVE_DEBUG}
    )
endif()

file(COPY       ${SOURCE_PATH}/include
                ${SOURCE_PATH}/share
    DESTINATION ${CURRENT_PACKAGES_DIR}
)
function(INSTALL_FILE PATTERN INSTALL_DIR)
    file(GLOB INSTALL_FILES ${PATTERN})
    file(INSTALL ${INSTALL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/${INSTALL_DIR})
endfunction()

if(VCPKG_TARGET_IS_WINDOWS)
    SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
    install_file("${SOURCE_PATH}/lib/*.dll" bin)
    install_file("${DEBUG_SOURCE_PATH}/lib/*.dll" debug/bin)
    install_file("${SOURCE_PATH}/lib/*.lib" lib)
    install_file("${DEBUG_SOURCE_PATH}/lib/*.lib" debug/lib)
    install_file("${DEBUG_SOURCE_PATH}/lib/*.pdb" debug/bin)

    file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/c10/cuda/test/impl
    ${CURRENT_PACKAGES_DIR}/include/c10/hip
    ${CURRENT_PACKAGES_DIR}/include/c10/test/core/impl
    ${CURRENT_PACKAGES_DIR}/include/c10/test/util
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/aten/docs
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/docker-ubuntu-14.04  
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/ideep
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/nnpack
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/opencl/OpenCL        
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/playground/resnetdemo
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/pytorch
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/script/examples
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/tensorboard
    ${CURRENT_PACKAGES_DIR}/include/caffe2/core/nomnigraph/Representations
    ${CURRENT_PACKAGES_DIR}/include/caffe2/experiments/python
    ${CURRENT_PACKAGES_DIR}/include/caffe2/ideep/operators/quantization
    ${CURRENT_PACKAGES_DIR}/include/caffe2/mobile/contrib/libopencl-stub/src
    ${CURRENT_PACKAGES_DIR}/include/caffe2/mobile/contrib/libvulkan-stub/src
    ${CURRENT_PACKAGES_DIR}/include/caffe2/operators/experimental/c10/cpu
    ${CURRENT_PACKAGES_DIR}/include/caffe2/opt/nql/tests
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/docs
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/examples
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/helpers
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/ideep
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/layers
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/mint/static/css
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/mint/templates
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/mkl
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/modeling
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/models/seq2seq
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/onnx/bin
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/onnx/tests
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/operator_test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/predictor
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/rnn
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/serialized_test/data/operator_test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/trt
    ${CURRENT_PACKAGES_DIR}/include/caffe2/share/contrib/depthwise
    ${CURRENT_PACKAGES_DIR}/include/caffe2/share/contrib/nnpack
    ${CURRENT_PACKAGES_DIR}/include/caffe2/test/assets
    ${CURRENT_PACKAGES_DIR}/include/caffe2/utils/hip
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/data/datasets
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/data/samplers
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/nn/modules
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/optim
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/python
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/serialize
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/jit/backends
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/jit/generated

    ${CURRENT_PACKAGES_DIR}/include/c10/test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/operators/experimental/c10
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/mint/static
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/models
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/onnx
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/serialized_test/data
    ${CURRENT_PACKAGES_DIR}/include/caffe2/test
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/data
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src/nn

    ${CURRENT_PACKAGES_DIR}/include/c10/cuda/test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/playground
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/script
    ${CURRENT_PACKAGES_DIR}/include/caffe2/operators/experimental
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/mint
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/serialized_test
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/api/src

    
    ${CURRENT_PACKAGES_DIR}/include/c10/benchmark
    ${CURRENT_PACKAGES_DIR}/include/caffe2/contrib/fakelowp/test
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/benchmarks
    ${CURRENT_PACKAGES_DIR}/include/caffe2/python/fakelowp
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/cuda/shared
    ${CURRENT_PACKAGES_DIR}/include/torch/csrc/jit/docs
    ${CURRENT_PACKAGES_DIR}/include/google
    ${CURRENT_PACKAGES_DIR}/include/THCUNN/doc
)
else()
    file(COPY       ${SOURCE_PATH}/lib
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )
endif()

file(DOWNLOAD https://raw.githubusercontent.com/pytorch/pytorch/master/LICENSE
              ${SOURCE_PATH}/copyright
)
file(INSTALL    ${SOURCE_PATH}/copyright
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtorch
)
