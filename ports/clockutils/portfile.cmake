vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClockworkOrigins/clockUtils
    REF 3651f232c27074c4ceead169e223edf5f00247c5
    SHA512 ddb70cae9ced25de77a2df1854dac15e58a77347042ba3ee9c691f85f49edbc6539c84929a7477d429fb9161ba24c57d24d767793b8b1180216d5ddfc5d3ed6a
    HEAD_REF dev-1.2
    PATCHES
        fix-warningC4643.patch
        add-missing-thread-header.patch
)

set(SHARED_FLAG OFF)
set(USE_MSBUILD "")
if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
    set(SHARED_FLAG ON)
    set(USE_MSBUILD WINDOWS_USE_MSBUILD) # MS Build only required for dynamic builds
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${USE_MSBUILD}
    OPTIONS
        -DWITH_LIBRARY_ARGPARSER=ON
        -DWITH_LIBRARY_COMPRESSION=ON
        -DWITH_LIBRARY_CONTAINER=ON
        -DWITH_LIBRARY_INIPARSER=ON
        -DWITH_LIBRARY_SOCKETS=ON
        -DWITH_TESTING=OFF
        -DCLOCKUTILS_BUILD_SHARED=${SHARED_FLAG}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
