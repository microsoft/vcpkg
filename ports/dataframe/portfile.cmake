vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF 1.10.0
    SHA512 33ce94732093e481e2aae6072cf1a76d6cd21853dde1db6efa8a803650a56199fcc950f51ef324934307e490c4f7eb4bc643de26a14076e64c9234c6fe5f8326
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
