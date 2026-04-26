set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_HEADER_ONLY enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviadCohen24/LockFreeRingBuffer
    REF "v${VERSION}"
    SHA512 d4063796e07136ddbafba4fdb23a3e6eec94f08aab4099c86849a4278d86ff015f961b96484be5097080e14f232390cc5a8e194190a3835c4747c30850cf49ef
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/ring_buffer.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
