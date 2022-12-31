vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF 39a4dab2504c9c26d3577d11a335027f8d782457
    SHA512  3bdbf12e26d0808818bcb3c28b398650656cabaf3bb364095b277d07f6e35afc6d3aaea9357e6a888dd92edfc0f88d655b59d186150f5b779e7511a924d713bd
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
