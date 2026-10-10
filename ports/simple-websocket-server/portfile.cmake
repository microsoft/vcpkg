set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LimiNode/Simple-WebSocket-Server
    REF v2.0.3-ln.1
    SHA512 bf66f797f7e00d89a42ad5ffb53d9e3c91695479739f8617c5d29d716eaa803321f153fb4cbd2644470ac69858f8f09f727a988631acab05d4956fe5c1ba39ed
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

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
