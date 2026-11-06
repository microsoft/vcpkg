vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kedixa/coke
    REF "v${VERSION}"
    SHA512 e8d401e5d9f0ef7a87c280ba1af65fe97578740c84af092374f334b066cc223e92ac03b31f1aac344cc5ef5fe6c567bfd2616b909eeb4fd179510ce79f10d2a5
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(_COKE_CONFIG_OPTIONS "-DCOKE_BUILD_STATIC=ON" "-DCOKE_BUILD_SHARED=OFF")
else()
    set(_COKE_CONFIG_OPTIONS "-DCOKE_BUILD_STATIC=OFF" "-DCOKE_BUILD_SHARED=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${_COKE_CONFIG_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/coke" PACKAGE_NAME coke)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

