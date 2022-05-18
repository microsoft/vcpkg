# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brunocodutra/metal
    REF 9db9b403e58e0be0bbd295ff64f01e700965f25d
    SHA512 b611d88d310893329f48111716c849571cb1459da1e71851bf3ec7393f18f8eb94077ce12410a9bcb1953e6b4ea0e8f2d2db5ce7f555a72ab2b7dae434b52d62
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME Metal
    CONFIG_PATH lib/cmake/Metal
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
