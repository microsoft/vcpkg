vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChampionUgrax/mercenary
    REF v1.0.0
    SHA512 "188b33c7e4d96bdb7ab1a58a44194a80145d59ae1d0bcd3375d4580165172c6923238f14dd40e7b4a0e97994d57eb53c846fcf3c996377b613cf5a134092ccc2"
)
#Move your header-only file directly into the system installation directory
file(INSTALL "${SOURCE_PATH}/include/mercenary.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

 
