vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wqking/eventpp
    REF v0.1.2
    SHA512 01fd536024dfef8c4025fc184f6b6326a901849dbf73d81430d7cfadeff25c9c140ab6a28b0143a4090703668c1d9e743a54e874c0321c3453cf40aeb4583db3
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
