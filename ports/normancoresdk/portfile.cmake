vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO norman-ml/norman_core_sdk_cpp
    REF v0.0.1
    SHA512 b54cfffeca6117f19d328a4538fd6c8b1936089bc86735b4a7522e8721ca7ff9a191dd6513a562530e135fe95dadb687d598e76315af30d7d1847d4bdbb0ed57
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/normancoresdk" RENAME copyright)
