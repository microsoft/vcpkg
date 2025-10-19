vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO norman-ml/norman_core_sdk_cpp
    REF v${VERSION}  
    SHA512 c2d0350c4b29eec65ed501335bd3e912a7e8ad3eddcf3c91ccbdad27275df680995406ce3f173521a08622b4ec6fc63ce10042153ac6ba315684b368caecfd11
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/normancoresdk" RENAME copyright)
