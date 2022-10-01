vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 4creators/jxrlib
    REF f7521879862b9085318e814c6157490dd9dbbdb4
    SHA512 f5617cbe73b6b905cc6bba181e6a3efedd59584f7a8c90e0f34db580cfdad4239a2ab753df4e221f26a5c0db51475b021052e3b9e3ab3673573573b1d57f3fdb
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jxr")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
