vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF v2.2.1
    SHA512 cf9f14e6bdbf2b739a25004c8f30ef8057cf4afa618c91fc2672059869cbbbdafb72f3027863b3f731f7f2cc239d5690e5e87301bf7930b79fe71d7a4ae3f833
    HEAD_REF master
    PATCHES
        fix-deps-and-build-type.patch
        #fix-error-c2668.patch
        #fix-error-C4996.patch  #fix x64-uwp error:std::uncaught_exception() is deprecated in C++17
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
