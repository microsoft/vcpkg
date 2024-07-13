
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/stdexec
    REF 089c4613385f808c3b39c4f4915f658157013a36
    SHA512 a9c1d4009b71bfc280801814272319312b8edcd3106c5fd8fdab6fc2eb2c64be4a01374026de02129389e4d2280599b14a3c037566a1bbefcd6b48c5052d583b
    HEAD_REF main
    PATCHES
        fix-version.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_RAPIDS
    REPO rapidsai/rapids-cmake
    REF v24.02.01
    SHA512 bb8f2b1177f6451d61f2de26f39fd6d31c2f0fb80b4cd1409edc3e6e4f726e80716ec177d510d0f31b8f39169cd8b58290861f0f217daedbd299e8e426d25891
    HEAD_REF main
)

vcpkg_download_distfile(RAPIDS_cmake
    URLS "https://raw.githubusercontent.com/rapidsai/rapids-cmake/v24.02.01/RAPIDS.cmake"
    FILENAME "RAPIDS.cmake"
    SHA512 e7830364222a9ea46fe7756859dc8d36e401c720f6a49880a2945a9ebc5bd9aa7e40a8bd382e1cae3af4235d5c9a7998f38331e23b676af7c5c72e7f00e61f0c
)
file(COPY "${RAPIDS_cmake}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")

vcpkg_download_distfile(execution_bs
    URLS "https://raw.githubusercontent.com/cplusplus/sender-receiver/a1790ddda5dcdf70f0658d0b50794649caa6c96f/execution.bs"
    FILENAME "execution.bs"
    SHA512 091c327eb1d161c46d77e7e0265c16d3de0c7fe7e1714c6891fbc6914d7147aed83ea28ba5a1f79703c9b00c84e7c2351fcf9106dacec46f634b0795692bc086
)
file(COPY "${execution_bs}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDEXEC_BUILD_TESTS=OFF
        -DSTDEXEC_BUILD_EXAMPLES=OFF
        -DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE="${SOURCE_PATH_RAPIDS}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stdexec)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
