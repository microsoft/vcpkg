include(vcpkg_common_functions)
set(PORT_VERSION 2.1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/IF97
    REF v${PORT_VERSION}
    SHA512 f8cde0538af395d8d82998bd71f28d89cd5c6fcfdf16410b0630a0f8b59ec86ff8a748b05681e65cbece051db5be6b960b6ea4fc8bce83b4309f46896083164a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/IF97.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/if97
  RENAME copyright
)
