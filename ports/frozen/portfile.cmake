vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge-sans-paille/frozen
    REF 1.1.1
    SHA512 e22561a4e634e388e11f95b3005bc711e543013d314f6aaeda34befb2c673aea2d71a717d8822bc8fa85bdc8409945ba2ad91a1bac4f8cb5303080de01a5f60e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dfrozen.benchmark=OFF
      -Dfrozen.coverage=OFF
      -Dfrozen.installation=ON
      -Dfrozen.tests=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/frozen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
