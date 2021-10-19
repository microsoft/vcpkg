vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/glog
    REF 8f9ccfe770add9e4c64e9b25c102658e3c763b73 #v0.5.0
    SHA512 93dab1041ef4e3eb758c76325531ae32208dcf92c296c8c3404cfa249b3849cc24d5423e087478b17f79ccbae9dbcabe049e509d47c4ec6d7135ca8ca80dada5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DWITH_PKGCONFIG=ON
        -DWITH_GTEST=OFF
        -DWITH_UNWIND=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)