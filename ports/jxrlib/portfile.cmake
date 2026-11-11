vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Upstream release 1.4.4 (2026-10-09). The port version keeps the date scheme of the old 4creators snapshot.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mircomir/jxrlib
    REF 1.4.4
    SHA512 3b77a2cbcf000b6decf006097f415d86156ab6dc70d3fa3069ddee31f04e610e2d644dec0fae96bf73ee4e5d1ca0390129fc650356da3e7446d6211b22d7df99
    HEAD_REF master
    PATCHES
        guiddef.patch
        fix-mingw.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindJXR.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jxr")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jxr")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
