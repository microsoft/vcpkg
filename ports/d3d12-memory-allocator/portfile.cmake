vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator 
    REF 10f148cef0dfd34ae1a9373b9396beb1581c992a
    SHA512 c99934a606ce5a5c9c59e05faf2e659bfad2e485b58aaf00f38219a6c89f17b62033f4a69935915f0d5269a4f0ecba41037b044913ae6f4077fa981eaab470c8
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake/)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
