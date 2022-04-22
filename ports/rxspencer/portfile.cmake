vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO garyhouston/rxspencer
    REF 9f835b523f1af617ca54e06863a1924c23f6e56a #v3.9.0
    SHA512 fe7721bd4b4e4f7d31fd5a7e42d34d0c9735d062d8b146ee47a25f87c809eead7133265fc37fa958c37bc4ffeaf101d143202080508d98efd160b8fd0a278598
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_CONFIG_DEST=share/rxspencer
        -Drxshared=${BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/rxspencer")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/regex")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
