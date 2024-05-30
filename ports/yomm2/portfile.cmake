vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jll63/yomm2
    REF "v${VERSION}"
    SHA512  cd697ece15456013b398452f881f0fd04e35aedf20169ce0a88c442af7a40dada84a6a4cabb702fc8564ece83e1966da2dedceb5598873f57ba209a0e65a440c
    HEAD_REF master
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
