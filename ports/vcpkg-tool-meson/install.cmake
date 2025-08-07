file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/meson")
file(INSTALL "${SOURCE_PATH}/meson.py"
             "${SOURCE_PATH}/mesonbuild"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/meson"
)
