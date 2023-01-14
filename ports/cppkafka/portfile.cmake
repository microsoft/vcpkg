vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/cppkafka
    REF v0.3.1
    SHA512 60d01ce1dd9bd9119676be939ed5ab03539abb1f945c1b31e432edfe0f06542778f7fef37696f5ff19c53024f44d5cbd8aeddbbb231c38b098e05285d3ff0cab
    HEAD_REF master
    PATCHES fix-dynamic.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(CPPKAFKA_BUILD_SHARED OFF)
else()
    set(CPPKAFKA_BUILD_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
       -DCPPKAFKA_BUILD_SHARED=${CPPKAFKA_BUILD_SHARED}
       -DCPPKAFKA_DISABLE_TESTS=ON
       -DCPPKAFKA_DISABLE_EXAMPLES=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)