vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF 58ca0f229aff093ada66955993cada93e01da18c #1.0.0
    SHA512 059f22460e147dcba9d92bd8afabca3c362541b70f49f8f2a19008dfbad66c59d1235720776f24cb84c95b3534e5ab0d093c76d352e7992fa44126c252c480f8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
