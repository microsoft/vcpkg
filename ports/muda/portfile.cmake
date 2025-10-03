vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "MuGdxy/muda"
    REF "${VERSION}"
    SHA512 2bffd348476d81520bdfcddde0829aea6fdae7c9e0e8ee1aa4ed0cf995d0de17550b7ac474465f3241f52b83c8422ca16e365bbbe8ec7d01750cfd9d4acef2c8
    HEAD_REF mini20
)

if("compute-graph" IN_LIST FEATURES)
    set(MUDA_WITH_COMPUTE_GRAPH ON)
else()
    set(MUDA_WITH_COMPUTE_GRAPH OFF)
endif()

if("nvtx3" IN_LIST FEATURES)
    set(MUDA_WITH_NVTX3 ON)
else()
    set(MUDA_WITH_NVTX3 OFF)
endif()

message(STATUS "[muda] Build with vcpkg port")
message(STATUS "[muda] Configuring with options:")
message(STATUS "[muda] - MUDA_BUILD_EXAMPLE=OFF")
message(STATUS "[muda] - MUDA_BUILD_TEST=OFF")
message(STATUS "[muda] - MUDA_WITH_CHECK=ON")
message(STATUS "[muda] - MUDA_WITH_NVTX3=${MUDA_WITH_NVTX3}")
message(STATUS "[muda] - MUDA_WITH_COMPUTE_GRAPH=${MUDA_WITH_COMPUTE_GRAPH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMUDA_BUILD_EXAMPLE=OFF
        -DMUDA_BUILD_TEST=OFF
        -DMUDA_WITH_CHECK=ON
        -DMUDA_WITH_NVTX3=${MUDA_WITH_NVTX3}
        -DMUDA_WITH_COMPUTE_GRAPH=${MUDA_WITH_COMPUTE_GRAPH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")