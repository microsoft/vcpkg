# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/rest_rpc
    REF "v${VERSION}"
    SHA512 1d88085acc6c4f913901631725acd08a688a079878677d064d441c3c89167275c5eed371d24e370feb88879ac06270e9316b91c67ea41e350523fe670406ecc1
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/rest_rpc.hpp"
    "#include \"rest_rpc/rpc_server.h\""
    "#define ASIO_STANDALONE\n#include \"rest_rpc/rpc_server.h\""
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-rest-rpc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-rest-rpc-config")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
