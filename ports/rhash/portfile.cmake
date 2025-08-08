vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF "v${VERSION}"
    SHA512 49bd6aa2497efc4871ae31eaca51d2dc78ceb7126311557d5280b14fafe9355eaecad37f0f78f865e4e1dd1aeb506d3301989cd2f9fff7b0091c81978e8c2f2e
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/librhash")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/librhash"
    OPTIONS
        -DRHASH_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-rhash)
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rhash.h" "# define RHASH_API" "# define RHASH_API __declspec(dllimport)")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
