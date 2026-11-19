vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/EGL-Registry
    REF 8e56e86e65687697ef54114cdb1afabdfac756bf
    SHA512 93dc83a7244506d7618be8863487d9aad3e225c1a7319af385f3bfd0bc842f7a487ae5f0b6911e4ff8fed2b5b450ea387a955a78bcc507a5d1861ae15b5f7f3e
    HEAD_REF main
)

file(
    COPY
       "${SOURCE_PATH}/api/KHR"
       "${SOURCE_PATH}/api/EGL"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(
    COPY
        "${SOURCE_PATH}/api/egl.xml"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/opengl"
)

vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")
