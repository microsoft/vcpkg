if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when msgpack is already installed, please remove msgpack using \"./vcpkg remove msgpack:${TARGET_TRIPLET}\"")
endif()

# header-only library
set(RESTRPC_VERSION V0.07)
set(RESTRPC_HASH 148152776c8c4f16e404c62ab3f46618e1817c0b4b186dbcc399c859efd110ed5a207bf56e961c312f80844f696f597068e0abc00e426409d50a2889d30c6d8e)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/rest-rpc-${RESTRPC_VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/rest_rpc
    REF ${RESTRPC_VERSION}
    SHA512 ${RESTRPC_HASH}
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/third/msgpack/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/rest_rpc.hpp"
    "#include \"rest_rpc/rpc_server.h\""
    "#define ASIO_STANDALONE\n#include \"rest_rpc/rpc_server.h\""
)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
