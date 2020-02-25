include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF 30c55d6544613c846368de1faee420e56e992ffe # v1.17.1
    SHA512 c4ed1492fd8733c6acabc973c58d6763e2a3a2bd7965fbf4d267169f5b03055eccdbe2723bc5d98636b039625a55609a092ed65de45d7a2b361347513cc83a98
    HEAD_REF master
    PATCHES
      0001-find-deps.patch
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

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/FindBlosc.cmake"
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
