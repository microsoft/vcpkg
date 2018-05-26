include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF v1.13.5
    SHA512 3ddc83c16c91d87959179f58bd23fe8e4bbd07c17312cdfdd0bc238a743e695f2914baf0b69efd923e8e54e8455699c8e528d3966d9126e15a8897d3c529db25
    HEAD_REF master
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

if (BLOSC_SHARED)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/blosc.dll ${CURRENT_PACKAGES_DIR}/debug/bin/blosc.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/blosc.dll ${CURRENT_PACKAGES_DIR}/bin/blosc.dll)
endif()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSES/BLOSC.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/blosc RENAME copyright)

