vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "MuGdxy/muda"
    REF "${VERSION}"
    SHA512 c9b43735b6857497fa422cbf59bf31a6665479ec63a91079741f45685b18e982031d6544ae21caee4f8f294ccff326c3caafde6c315b7775b06d0f7e63761309
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")