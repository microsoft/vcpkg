if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jemalloc/jemalloc-cmake
    REF jemalloc-cmake.4.3.1
    SHA512 e94b62ec3a53acc0ab5acb247d7646bc172108e80f592bb41c2dd50d181cbbeb33d623adf28415ffc0a0e2de3818af2dfe4c04af75ac891ef5042bc5bb186886
    HEAD_REF master
)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-utilities.patch"
)

vcpkg_configure_cmake(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DGIT_FOUND=OFF -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jemalloc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jemalloc/COPYING ${CURRENT_PACKAGES_DIR}/share/jemalloc/copyright)
