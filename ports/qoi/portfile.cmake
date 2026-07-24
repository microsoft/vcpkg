#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO phoboslab/qoi
    REF 4461cc37ef08b24f157a5ab7c3f7d6c9e6caa6c0 # committed on 2025-05-09
    SHA512 ab3f8e0e6a02e9e481e4d44a1b7809360ad013e25c8c58e84ea0ea03317dd5fc0acc26f7a30ac226714c45cc9dabe45f979dd7a4b0571ae5c6051f4bb0db6d9f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/qoi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
