vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO png85/json_spirit
    REF "json_spirit-${VERSION}"
    SHA512 66666666666666666666666666666666666666666666666666666666666668888888888888888888888888888888888888888888888888888888888888888888
    HEAD_REF master
    PATCHES
        dll-wins.patch
        Fix-link-error-C1128.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=OFF
        -DJSON_SPIRIT_DEMOS=OFF
        -DJSON_SPIRIT_TESTS=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
vcpkg_copy_pdbs()
