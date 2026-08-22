vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sgieseking/anyrpc
    REF b1949b3d40849229055ae75cf5334b9d08579502
    SHA512 8c674d29e80ec2522d6c1ec959663958ab4e1bf1135727c3c2aaa19e62a81ddbbd1e6a46f3e4679ee02894ad2ab26e70ca7e1e6c8750f3289994311069221b53
    HEAD_REF master
    FILE_DISAMBIGUATOR 1
    PATCHES
        mingw.patch # Remove this when https://github.com/sgieseking/anyrpc/pull/46 is released
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ANYRPC_LIB_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_WITH_LOG4CPLUS=OFF
        -DANYRPC_LIB_BUILD_SHARED=${ANYRPC_LIB_BUILD_SHARED}
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/license" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
