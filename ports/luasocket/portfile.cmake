vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lunarmodules/luasocket
    REF "v${VERSION}"
    SHA512 1e9e98484740ec6538fe3d2b0dab74d31f052956ecf9ee3b60e229f2d0b13fcc6d4aaf74cd2a3e2ee330333dabb316fe6a43c60baaea26f0cc01069b6aa4519b
    HEAD_REF master)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TYPE=${BUILD_TYPE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove debug share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
