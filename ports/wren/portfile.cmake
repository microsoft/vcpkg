vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wren-lang/wren
    REF 4a18fc489f9ea3d253b20dd40f4cdad0d6bb40eb #0.4.0
    SHA512 b3d79e9cb647e52db06d5cddfc8c93d05ae0e8d87f0f879ac2b812fcc7f55e018d21d3b04d62eaeb12e6d931b5e43fbe357b187e7f446e86e39be015c51c2eee
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMPILE_AS_CPP=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
