vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ikalnytskyi/termcolor
    REF b3cb0f365f8435588df7a6b12a82b2ac5fc1fe95 #v2.1.0
    SHA512 8a95c654b68728a2258eba1c40daf0e5cc69ba24e15e839f75341a694a20a930c042820d68c661ca1971b68dcc93f895513dc73774818b94e205a3a73199b550
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${port}/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
