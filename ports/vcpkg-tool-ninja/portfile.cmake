set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_download_distfile(
    LONG_PATH_PATCH
    URLS "https://patch-diff.githubusercontent.com/raw/ninja-build/ninja/pull/2056.diff" # stable?
    FILENAME 2056.diff
    SHA512 90f17c2cbb5e0c5b41de748f75a3fc3e0c9da8837a0507c8570a49affe15ae7258661dc1f1bc201574847d93ea8b7fe4cbecfffd868395d50ca821033c5f295d
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ninja-build/ninja
    REF 170c387a7461d476523ae29c115a58f16e4d3430
    SHA512 75c0f263ad325d14c99c9a1d85e571832407b481271a2733e78183a478f7ecd22d84451fc8d7ce16ab20d641ce040761d7ab266695d66bbac5b2b9a3a29aa521
    HEAD_REF master
    PATCHES "${LONG_PATH_PATCH}" # Long path support windows
)
set(VCPKG_BUILD_TYPE release) #we only need release here!
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_tools(
    TOOL_NAMES ninja
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/ninja"
    AUTO_CLEAN
)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
