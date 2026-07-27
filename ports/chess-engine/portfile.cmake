vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ByteMe6/chess-engine
    REF "v${VERSION}"
    SHA512 4cf92b26c135cb87c4aff96fb41a2bce71f7f60de6fdf8a67675cd941927a5d1d5be3570cb97afdbe582d02c4375597275cedc42b1cffe83f6fe22fb590c7b9e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/chessEngine.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
