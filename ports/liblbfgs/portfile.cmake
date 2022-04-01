vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chokkan/liblbfgs
    REF v1.10
    SHA512 2b08dc5d4fdd737575f58983fa7b6c143bc12edaca47b7aeadf221afe6e573fa4a53423f323f569aa93c9dbeafb9b80a6d2f755fec6da04e6b7221f0a67816f8
    HEAD_REF master
)

message(STATUS "source path is : ${SOURCE_PATH}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/liblbfgs" RENAME copyright)