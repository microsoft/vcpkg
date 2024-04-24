vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jll63/yomm2
    REF "v${VERSION}"
    SHA512  5b2c4e68df88893e0179f355da255401bc13863079a040c6b3b942c6be076263911bde51afca73e69fbb1e8bec5bc0f9d9549974bdd8ab01ea8dc571dcf8de4b
    HEAD_REF master
    PATCHES "fix_install.patch"
)

set(YOMM2_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE MATCHES "dynamic")
    set(YOMM2_SHARED ON)
endif()

if(VCPKG_LIBRARY_LINKAGE MATCHES "static")
    set(VCPKG_BUILD_TYPE release) # header-only
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DYOMM2_ENABLE_EXAMPLES=OFF
        -DYOMM2_ENABLE_TESTS=OFF
        -DYOMM2_SHARED=${YOMM2_SHARED}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/YOMM2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE MATCHES "static") # header only library in static build
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
