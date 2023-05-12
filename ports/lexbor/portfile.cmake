vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexbor/lexbor
    REF v${VERSION}
    SHA512 26bbca3b41a417cbc59ba8cf736e1611966fc2202de85aabf621b840565d835e7e5ffc1b0294defc16ec883f9fb94e802bd19ed704be35fa79b41566acc05cbc
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(LEXBOR_BUILD_SHARED OFF)
    set(LEXBOR_BUILD_STATIC ON)
else()
    set(LEXBOR_BUILD_SHARED ON)
    set(LEXBOR_BUILD_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DLEXBOR_BUILD_SHARED=${LEXBOR_BUILD_SHARED}
    -DLEXBOR_BUILD_STATIC=${LEXBOR_BUILD_STATIC}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/include/lexbor/html/tree/insertion_mode"
    "${CURRENT_PACKAGES_DIR}/debug/include/lexbor/html/tree/insertion_mode"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
