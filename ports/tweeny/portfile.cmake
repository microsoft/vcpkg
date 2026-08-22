vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/tweeny
    REF v${VERSION}
    SHA512 f752db8ff5fdff696eb6449adc98af875753e22a9235c059f052dd43aa245e2c510b6c3d25dc52cd350d5f0712f8565364e07790998e4aebf0eb2658f7754bc3
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "/lib/cmake/Tweeny/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake/Tweeny")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
