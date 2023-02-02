vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lltcggie/readline
    REF ea414b4e98475e3976198738061824e8a8379a50
    SHA512 82d54ab3e19fb2673fe97eff07117d36704791669baa283ec737c704635f872e4c7cd30485a6648d445cb2912e4364286e664e9425444f456a4c862b9e4de843
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/src/readline/5.0/readline-5.0-src")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h" DESTINATION "${SOURCE_PATH}/src/readline/5.0/readline-5.0-src")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src/readline/5.0/readline-5.0-src"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-readline-win32)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/src/readline/5.0/readline-5.0-src/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
