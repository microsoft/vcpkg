vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF 9bd4bc25275066fa03173f65e1cbd789472e8f9b # 2.17.0
    SHA512 8b665e6307e73ad3273eb28c17ec62e8d0d968623d41b5460771be41a74f6a8088ddadb1764b9b4dc496dbceae6e791895cee0997de8614dc9a7426b6db663e0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ensmallen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
