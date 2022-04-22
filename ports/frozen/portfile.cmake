vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge-sans-paille/frozen
    REF 867b33916044ced463ed42874b2aa1514ef66bec
    SHA512 0cace261bf6068a382dc7c2d2b1c7d50de882e966adcdaaee7c358cc2e55b736d41c6ce2cefb30c231f550e4576cfdc5b2a10379a8affa084f1eb9202db7200e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -Dfrozen.benchmark=OFF
      -Dfrozen.coverage=OFF
      -Dfrozen.installation=ON
      -Dfrozen.tests=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/frozen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
