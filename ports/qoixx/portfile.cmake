#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wx257osn2/qoixx
    REF eac3b33fbcb96a2664c00c24fe4e3e0d35cc7a7e # committed on 2022-12-07
    SHA512 5dd379036e064527cb25376864fb6e6cb3d461baf95a6c98148202a8072f049ae0edfbac17bf76550eeb1f367d2426b6edd0a86b9231d50bb66771878df207c4
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/qoixx.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
