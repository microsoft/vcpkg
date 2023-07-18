vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wqking/eventpp
    REF 9231cbb93ba71ae5935aa503434a3faed275e8d8 #2023-05-16
    SHA512 bb58dc81cd9f88b2093c94fbd5b5c6b70012ced5d73745ff0fcf6858595d55ba38c71edc2f28303de19dce31d24573218094dedbf283cd3e8dda91348c0853f2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/eventpp")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/license" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
