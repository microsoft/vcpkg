vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebm
    REF 82a1d2330e113a14e545d806eb5419f09374255f #1.0.0.28
    SHA512 7baf6f702f0e4498c9b0affebeba3ff28192c5f3dadfa5a17db2306816b3a9e31ce7a474e4d344ba136e5acf097c32d4ff61ce99861d427cdfb2f20e317d7e15
    HEAD_REF master
    PATCHES
        Fix-cmake.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=dll)
else()
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${LIBWEBM_CRT_LINKAGE}
    -DENABLE_SAMPLES=OFF
    -DENABLE_TOOLS=OFF
    -DENABLE_WEBMTS=OFF
    -DENABLE_WEBMINFO=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)