vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO png85/json_spirit
    REF 5e16cca59b31d8beda0f07e3917ce11dcd43b3db
    SHA512 6ac0f15726391c9003e516213535c8d30e98b6c33bca0b03e9bf38e7085824bfc6cfaab267b1dfccbfcc567638d26f722d7e331f4e3b60d3acd5c717cb1fafcc
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
