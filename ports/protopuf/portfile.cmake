vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF v2.2.1
    SHA512 f7cf0df90178f2582ba50f6fb8518b4a005dbad7d0fb1fea8f0b2d80a3df18d251b0c795583a121aab246acf245a46ecf374597447b7b61777e48c5bfafed5f2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
