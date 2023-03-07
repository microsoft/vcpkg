vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chemag/h265nal
    REF v0.38
    SHA512 690f7596c12f3f71e6ef2d37c2f2c5bd4714530d0467a8a946230d728f0b224164a966334d0e7c744c5d4cd7888e8e3ff5cde196ab73c7476ae688ce2ba6f268
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

file(
    INSTALL "${SOURCE_PATH}/LICENSE" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright
    )