vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imakris/mexce
    REF "${VERSION}"
    SHA512 aecd9497195da71075d55fe57b77e69d3824d552a9fc97bc2d5f65acaee1eb1d436733233608351cf372dee6ead2549c390ae13af61d814a60caabc0336b2695
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/mexce.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
