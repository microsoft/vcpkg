vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jll63/yomm2
    REF "v${VERSION}"
    SHA512  35d869f79b278ae219d61e0ae3b01902c5df5457d2ced7bfd109cf0e75f3f7835ce3d4751c34838d134531f6483dc89b7d67d5ecab6e8af42b4b735284573db4
    HEAD_REF master
    PATCHES "fix_install.patch"
)

set(YOMM2_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE MATCHES "dynamic")
    set(YOMM2_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DYOMM2_ENABLE_EXAMPLES=OFF
        -DYOMM2_SHARED=${YOMM2_SHARED}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/YOMM2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE MATCHES "static") # header only library in static build
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
