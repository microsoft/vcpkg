vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/stk
    REF 4.6.1
    SHA512 61d4db7b4a45446e231dedc13e139cb488e2ce805278f0b20aa95e69ddb1fa9be549ab5f1fe24c69aa865ebc2940d5fba6e3819a1a7fb1d68e236131fcfb4cac
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libstk)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(GLOB RAWFILES "${SOURCE_PATH}/rawwaves/*.raw")
file(COPY ${RAWFILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/libstk/rawwaves")
