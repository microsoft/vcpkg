set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO phoboslab/qoi
    REF ffb2d2cb74a1de60819b21b939f7209aa53e91c1 # committed on 2026-09-27
    SHA512 afdac37acbf5cfc834047a7620eb8ba54c3a01be5c31af7a42528871d674607a8c333af0fc1211107616530412ec12a57bd11e5037a4f6592955cf014b6c3b83
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/qoi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
