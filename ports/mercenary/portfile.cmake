vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChampionUgrax/mercenary
    REF v1.0.0
    SHA512 "3eb477610dc850024976798a72887309007e5f17dcd8ab305e7e8b9195d8cd3f6a27bf79135767b93a0b12f7142d765ee4615a9e3a6c2f7b8f9a2f7c6e6b5d4c"
)
#Move your header-only file directly into the system installation directory
file(INSTALL "${SOURCE_PATH}/include/mercenary.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

 
