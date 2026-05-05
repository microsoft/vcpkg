vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/ecaludp
    REF "v${VERSION}"
    SHA512 4f9d8c67777a63b569bd7069ca2a43eaaaa898a429c206bccfd5e90b10a733aa5f138be059cef2fcebda53987fdf0583b1d1859ecd154b9a48b5d39afd21c637
    HEAD_REF master
    PATCHES
        find-recycle.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(ECALUDP_LIBRARY_TYPE "SHARED")
else()
    set(ECALUDP_LIBRARY_TYPE "STATIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DECALUDP_LIBRARY_TYPE=${ECALUDP_LIBRARY_TYPE}
        -DECALUDP_BUILD_SAMPLES=OFF
        -DECALUDP_BUILD_TESTS=OFF
        -DECALUDP_ENABLE_NPCAP=OFF
        -DECALUDP_USE_BUILTIN_ASIO=OFF
        -DECALUDP_USE_BUILTIN_RECYCLE=OFF
        -DECALUDP_USE_BUILTIN_UDPCAP=OFF
        -DECALUDP_USE_BUILTIN_GTEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ecaludp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
