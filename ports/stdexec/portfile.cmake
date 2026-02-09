if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/stdexec
    REF 8cfc3f1983d3521b341864074123281011f998c1
    SHA512 6f06efe9f5d8178980982d984e1d4f386a702dd55e1b745d34cee614d323b6b16386106b9c7d88cf71432ac72f46dec2dec70ca29e1098e4806f5e7982e16018
    HEAD_REF main
    PATCHES
        fix-version.patch
        fix-clangd-helper-file-basedir.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_RAPIDS
    REPO rapidsai/rapids-cmake
    REF v24.02.01 # stable tag (stdexec wants branch-24.02)
    SHA512 bb8f2b1177f6451d61f2de26f39fd6d31c2f0fb80b4cd1409edc3e6e4f726e80716ec177d510d0f31b8f39169cd8b58290861f0f217daedbd299e8e426d25891
    HEAD_REF main
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" 
    [[file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-24.02/RAPIDS.cmake]]
    "file(COPY_FILE \"${SOURCE_PATH_RAPIDS}/RAPIDS.cmake\""
)

vcpkg_download_distfile(execution_bs
    URLS "https://raw.githubusercontent.com/cplusplus/sender-receiver/12fde4af201017e49efd39178126f661a04dbb94/execution.bs"
    FILENAME "execution.bs"
    SHA512 90bb992356f22e4091ed35ca922f6a0143abd748499985553c0660eaf49f88d031a8f900addb6b4cf9a39ac8d1ab7c858b79677e2459136a640b2c52afe3dd23
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" 
    [[file(DOWNLOAD "https://raw.githubusercontent.com/cplusplus/sender-receiver/main/execution.bs"]]
    "file(COPY_FILE \"${execution_bs}\""
)

# stdexec uses cpm (via rapids-cmake).
# Setup a local cpm cache from assets cached by vcpkg
file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/cpm")
# Version from rapids-cmake cpm/detail/download.cmake
set(CPM_DOWNLOAD_VERSION 0.38.5)
vcpkg_download_distfile(CPM_CMAKE
    URLS https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
    FILENAME CPM_${CPM_DOWNLOAD_VERSION}.cmake
    SHA512 a376162be4fe70408c000409f7a3798e881ed183cb51d57c9540718fdd539db9028755653bd3965ae7764b5c3e36adea81e0752fe85e40790f022fa1c4668cc6
)
file(INSTALL "${CPM_CMAKE}" DESTINATION "${CURRENT_BUILDTREES_DIR}/cpm/cpm")

# Version and patch from stdexec CMakeLists.txt
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_ICM
    REPO iboB/icm
    REF v1.5.0 # from stdexec CMakeLists.txt
    SHA512 0d5173d7640e2b411dddfc67e1ee19c921817e58de36ea8325430ee79408edc0a23e17159e22dc4a05f169596ee866effa69e7cd0000b08f47bd090d5003ba1c
    HEAD_REF master
    PATCHES
        "${SOURCE_PATH}/cmake/cpm/patches/icm/regex-build-error.diff"
)

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDEXEC_BUILD_TESTS=OFF
        -DSTDEXEC_BUILD_EXAMPLES=OFF
        "-DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE=${SOURCE_PATH_RAPIDS}"
        "-DCPM_SOURCE_CACHE=${CURRENT_BUILDTREES_DIR}/cpm"
        "-DCPM_icm_SOURCE=${SOURCE_PATH_ICM}"
        "-DGIT_EXECUTABLE=${GIT}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stdexec)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
