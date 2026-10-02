set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eidheim/Simple-WebSocket-Server
    REF v2.0.2
    SHA512 647238bb1dc69e816846c777fd7b4cb2c1ce7d4e899791b72ce1acd9704ec7d8d6598e4d094ffb3da4ac4b100a55663d9c71ff8e8b829caec0a2f39d333d0775
    HEAD_REF master
)

file(COPY
    "${SOURCE_PATH}/asio_compatibility.hpp"
    "${SOURCE_PATH}/client_ws.hpp"
    "${SOURCE_PATH}/client_wss.hpp"
    "${SOURCE_PATH}/crypto.hpp"
    "${SOURCE_PATH}/mutex.hpp"
    "${SOURCE_PATH}/server_ws.hpp"
    "${SOURCE_PATH}/server_wss.hpp"
    "${SOURCE_PATH}/status_code.hpp"
    "${SOURCE_PATH}/utility.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
