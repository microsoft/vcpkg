# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/rest_rpc
    REF "v${VERSION}"
    SHA512 59c9ca70ae53809b2710cc83c7a338a05d9bc76840def7786ee940f9a3cc03c88040a7b721980114d231042608dab23d6061cbc5ebe4dcda984989beec056eda
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/rest_rpc.hpp"
    "#include \"rest_rpc/rpc_server.hpp\""
    "#define ASIO_STANDALONE\n#include \"rest_rpc/rpc_server.hpp\""
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-rest-rpc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-rest-rpc-config")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
