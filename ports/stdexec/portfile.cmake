
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
    REF c7a28304639a2ed460181b4753f3280c7833c718
    SHA512 9a87fdef490199337778b8c9b4df31ca37d65df23803d058f13b406dcfda4d96d992b2780b0b878b61b027c0dc848351496a0f32e779f95298f259bab040b49b
    HEAD_REF main
)

vcpkg_download_distfile(RAPIDS_cmake
    URLS "https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-23.02/RAPIDS.cmake"
    FILENAME "RAPIDS.cmake"
    SHA512 e7830364222a9ea46fe7756859dc8d36e401c720f6a49880a2945a9ebc5bd9aa7e40a8bd382e1cae3af4235d5c9a7998f38331e23b676af7c5c72e7f00e61f0c
)
file(COPY "${RAPIDS_cmake}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")

vcpkg_download_distfile(execution_bs
    URLS "https://raw.githubusercontent.com/cplusplus/sender-receiver/main/execution.bs"
    FILENAME "execution.bs"
    SHA512 90bb992356f22e4091ed35ca922f6a0143abd748499985553c0660eaf49f88d031a8f900addb6b4cf9a39ac8d1ab7c858b79677e2459136a640b2c52afe3dd23
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
