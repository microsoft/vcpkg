vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tibogens/OpenThreads
    REF "${VERSION}"
    SHA512 dea48db0984ac64992f464358598dab4ebf67c2c5d6894e681fca31cc8fff976d606abd41c307456dba2c81248b13e8210d871a31932522fdb81d0ad00b1fa61
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${VCPKG_LIBRARY_LINKAGE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
