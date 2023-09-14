vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chokkan/crfsuite
    REF a2a1547727985e3aff6a35cffe073f57f0223e9d
    SHA512 d80f72fe13288bc516772542438c09439c6abbd4c15b06650f1de1fee7f7f710c1eed924d4300141807b8f86af398ae5d217974c13a65044515ceb163de441a4
    HEAD_REF master
)

list(REMOVE_ITEM SOURCE_FILE "${SOURCE_PATH}/win32/liblbfgs/lbfgs.lib")
list(REMOVE_ITEM SOURCE_FILE "${SOURCE_PATH}/win32/liblbfgs/lbfgs_debug.lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
