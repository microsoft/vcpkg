vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuminoEngine/Lumino
    REF e3f0df1c812ee3a4f7de5bb2fc600065ec804a0b
    SHA512 010b7af70aa56d84b9287e6f3a3f11ffc640ea07dc9c3ac7b86e9ed3f3a9ed7a752085dc0fe194edd532bb3bdb86a7349e0aa437b0a365668c8eba3e13ee4c4f
    HEAD_REF main
)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
#file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libogg" RENAME copyright)

# certutil -hashfile ./Lumino-main.zip SHA512
