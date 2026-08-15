vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO triton-inference-server/client
    REF 67fc23833a2d67edd2840db9f828ca6b75a0336c
    SHA512 532a2fd8db86c9727fa186a6b5bce768f4ad2703099a0260ad2619893083090157e3935075b2cfbecca7e91799d4d1cfc9748e095a6a532968f5cb71672e23cc
    HEAD_REF main
    PATCHES
        fix-install.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH COMMON_SOURCE_PATH
    REPO triton-inference-server/common
    REF ecb874c3126f9f07810f4900d4e7b088fee5eb8c
    SHA512 fc1ce157c6ae337d45225fda8e22ebbdbacf7e91def9401fbded99a19300c3457e62744a05324b3f32102d5e88c7d7b0fbbf9c84bcc1b7dbd2b5926cf0ad0491
    HEAD_REF main
    PATCHES
        fix-common-install.patch
)

set(KEEP_TYPEINFO OFF)
if(VCPKG_TARGET_IS_OSX)
    set(KEEP_TYPEINFO ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src/c++"
    OPTIONS
        "-DFETCHCONTENT_SOURCE_DIR_REPO-COMMON=${COMMON_SOURCE_PATH}"
        -DTRITON_ENABLE_CC_HTTP=ON
        -DTRITON_ENABLE_CC_GRPC=ON
        -DTRITON_ENABLE_EXAMPLES=OFF
        -DTRITON_ENABLE_TESTS=OFF
        -DTRITON_ENABLE_GPU=OFF
        -DTRITON_ENABLE_ZLIB=ON
        -DTRITON_USE_THIRD_PARTY=OFF
        "-DTRITON_KEEP_TYPEINFO=${KEEP_TYPEINFO}"
        -DTRITON_COMMON_ENABLE_PROTOBUF_PYTHON=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME TritonClient
    CONFIG_PATH lib/cmake/TritonClient
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME TritonCommon
    CONFIG_PATH lib/cmake/TritonCommon
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${COMMON_SOURCE_PATH}/LICENSE"
)

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
