vcpkg_from_github(
        OUT_SOURCE_PATH source
        REPO saadshams/nanojson
        REF 1.0.0
        SHA512 0
        HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nanojson" RENAME copyright)