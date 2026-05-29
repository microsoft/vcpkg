vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nitroshare/qhttpengine
    REF 43f55df51623621ed3efb4e42c7894586d988667
    SHA512 bf615016b9078ff1b3b47bb0d0329565d2d44caba67a3a207c430e7f03a7b5d8b326268fafa2b8ebff387aec9356014ec5510e18a422dd2dea7eb1e9bfc009f3
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
