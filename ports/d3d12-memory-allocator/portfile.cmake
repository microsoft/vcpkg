vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF 10f148cef0dfd34ae1a9373b9396beb1581c992a
    SHA512 c99934a606ce5a5c9c59e05faf2e659bfad2e485b58aaf00f38219a6c89f17b62033f4a69935915f0d5269a4f0ecba41037b044913ae6f4077fa981eaab470c8
    HEAD_REF master
    PATCHES single_header.patch
)

file(COPY "${SOURCE_PATH}/src/D3D12MemAlloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-d3d12-memory-allocator-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-d3d12-memory-allocator)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
