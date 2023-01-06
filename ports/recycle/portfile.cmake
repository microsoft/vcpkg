vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinwurf/recycle
    REF "${VERSION}"
    SHA512 7fff2d8d8da0613d330d58b0f82fafd7fc20b78ac2588ba9743dc8033f130acaf29b37f4c2c02f8b39fc8d5b352f589c6e8398420161124a7143ca4ca6521512
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
