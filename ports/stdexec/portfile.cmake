
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/stdexec
    REF 6b9f3501dced0e39611f93ff795da83d24364f30
    SHA512 d9a88b5095234c114cc45cef352662677b9f832065f3eec9c0f371547a5627672c3cf85ca19de702b2cd78ba5c1653b5e8156abe2f52d1e27ba014929b9336f2
    HEAD_REF main
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
    URLS "https://raw.githubusercontent.com/brycelelbach/wg21_p2300_execution/R7/execution.bs"
    FILENAME "execution.bs"
    SHA512 90f2a1d150b03c29bb05a5420e091c2371cb973335a089916716d778bc1081764436dc1ff0fec60f642ddb0ca5492c8b0c3a6d5451c2d60a42911f918fe980fa
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
