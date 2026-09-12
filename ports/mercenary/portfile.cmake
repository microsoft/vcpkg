vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChampionUgrax/mercenary
    REF v1.0.0
    SHA512 ""
)
#Move your header-only file directly into the system installation directory
file(INSTALL "${SOURCE_PATH}/include/mercenary.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
