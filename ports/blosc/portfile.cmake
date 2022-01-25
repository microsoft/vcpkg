vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF 9fae1c9acb659159321aca69aefcdbce663e2374 # v1.18.1
    SHA512 6cc77832100041aca8f320e44aa803adc0d3344b52742b995a3155b953e5d149534de65c8244d964448150b73715a81f54285d7d01f1b45d7b10fe07f5bdb141
    HEAD_REF master
    PATCHES
      0001-find-deps.patch
      0002-export-blosc-config.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BLOSC_STATIC ON)
    set(BLOSC_SHARED OFF)
else()
    set(BLOSC_STATIC OFF)
    set(BLOSC_SHARED ON)
endif()

file(REMOVE_RECURSE ${SOURCE_PATH}/internal-complibs)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPREFER_EXTERNAL_LZ4=ON
            -DPREFER_EXTERNAL_SNAPPY=ON
            -DPREFER_EXTERNAL_ZLIB=ON
            -DPREFER_EXTERNAL_ZSTD=ON
            -DBUILD_TESTS=OFF
            -DBUILD_BENCHMARKS=OFF
            -DBUILD_STATIC=${BLOSC_STATIC}
            -DBUILD_SHARED=${BLOSC_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/blosc)

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSES/BLOSC.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/blosc RENAME copyright)

vcpkg_fixup_pkgconfig()
