vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF tmx_1.2.0
    HEAD_REF master
    SHA512 cb29c67af560a1844e798d3fe2677a6b71866943b233c0700212b91de35f252a0a465c33911a2c432aa54be309e3ac10770bc95c6450227e39abe049c1fbbdd1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxExports.cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxTargets.cmake")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tmx)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/tmx/tmxTargets.cmake" "${CURRENT_PACKAGES_DIR}/share/tmx/tmxExports.cmake")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
