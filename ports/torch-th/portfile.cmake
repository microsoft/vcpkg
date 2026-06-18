vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO torch/torch7
    REF dde9e56fb61eee040d7f3dba2331c6d6c095aee8
    SHA512 ef813e6f583f26019da362be1e5d9886ecf3306a2b41e5f7a73d432872eacd2745e0cf26bfcc691452f87611e02e302c54f07b2f3a3288744535e57d154a73db
    HEAD_REF master
    PATCHES
        debug.patch
        fix-arm64-osx-config.patch
        fix-cmake4.patch # Note: The portfile currently deletes all cmake files
)

file(REMOVE "${SOURCE_PATH}/lib/TH/cmake/FindBLAS.cmake")
file(REMOVE "${SOURCE_PATH}/lib/TH/cmake/FindLAPACK.cmake")
file(REMOVE "${SOURCE_PATH}/lib/TH/cmake/FindMKL.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lib/TH"
    OPTIONS
        -DWITH_OPENMP=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/torch-th" RENAME copyright)
