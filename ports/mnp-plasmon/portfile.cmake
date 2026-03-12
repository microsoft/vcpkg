vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO galihru/mnpbem
    REF v0.1.0
    SHA512 3e84ae0a02a15bcff737184608cf934614c8a1a4c9d03929e75693bf043128884e9343884e44d0487f843d3a9ef8a560bc248c6cd752490cccae0a58780c6512
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c-mnp-plasmon"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/c-mnp-plasmon/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
