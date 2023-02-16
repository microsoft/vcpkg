vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zenomt/rtmfp-cpp
    REF 18168ec641df5bbe22a0fac84b0efc02a4bc0a67
    SHA512 eea3e4b52a4639dce3ff3f88011ae5b2f07dbeb7237f854b9b3f1a829c04af930c8edfa3a1a3cad95890a372fc6cc436b00c4dadf9b06fc404f50bdd36634a08
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup (CONFIG_PATH lib/cmake/rtmfp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
