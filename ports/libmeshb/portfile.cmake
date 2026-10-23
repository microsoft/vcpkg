if(VERSION MATCHES "^([0-9]+)\\.([0-9])$")
    set(TAG_VERSION "${CMAKE_MATCH_1}.0${CMAKE_MATCH_2}")
else()
    set(TAG_VERSION "${VERSION}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LoicMarechal/libMeshb
    REF "v${TAG_VERSION}"
    SHA512 c9b9548c325490b0625e4de84e4b5aad412635c7f512326eb2ef27fc4b98de28d661a0076ac5c31c64d74dea2e5dfd1222b19f0d7b22d313144ce8d35a78bfbf
    PATCHES
        disable_examples_utilities.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libMeshb")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/copyright.txt"
        "${SOURCE_PATH}/LICENSE.txt"
)
