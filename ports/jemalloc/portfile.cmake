vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jemalloc/jemalloc-cmake
    REF jemalloc-cmake.4.3.1
    SHA512 e94b62ec3a53acc0ab5acb247d7646bc172108e80f592bb41c2dd50d181cbbeb33d623adf28415ffc0a0e2de3818af2dfe4c04af75ac891ef5042bc5bb186886
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-utilities.patch
        fix-static-build.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC_LIBRARY OFF)
else()
    set(BUILD_STATIC_LIBRARY ON)
endif()
vcpkg_configure_cmake(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DGIT_FOUND=OFF -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON -Dwithout-export=${BUILD_STATIC_LIBRARY}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jemalloc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jemalloc/COPYING ${CURRENT_PACKAGES_DIR}/share/jemalloc/copyright)
