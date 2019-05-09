include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF v0.15.6
    SHA512 ba5dc18412ecceadb48e3c0f9b6f6d9ea920b76c36b12456bc96198346149010257c0f7807a1e1cc262ae0eca07e1994d3f1e3be0b3c815ce455d778c5375311
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/src ${CURRENT_PACKAGES_DIR}/include/uwebsockets/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)

