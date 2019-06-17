include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF v1.16.3
    SHA512 2ff67a6e955a641c3a2330140e5887d0ce3fdcbf6b205507798a4e848a35ba2e22bf8fd91133291bc73c4e48fb01c02139e47ab8e4774d0e2288872e625c9ffd
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

if (BLOSC_SHARED)
vcpkg_copy_pdbs()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/blosc.dll")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/blosc.dll ${CURRENT_PACKAGES_DIR}/bin/blosc.dll)
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/blosc.dll")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/blosc.dll ${CURRENT_PACKAGES_DIR}/debug/bin/blosc.dll)
    endif()
endif()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSES/BLOSC.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/blosc RENAME copyright)

