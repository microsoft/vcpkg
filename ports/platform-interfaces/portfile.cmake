vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linksplatform/Interfaces
    REF 0.4.0_0.2.5
    SHA512 6d54ee99844e49b4a7ed15b9fa5176e2e4cd4b739d4c5a976dc1b4346df2c53197968f52d2dc1849d85a80c6e9999de98e43c7a770f3b54b44f9a2aa1fa0ffb2
    HEAD_REF master
)


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/cpp/Platform.Interfaces DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/platform-interfaces/platform-interfaces-config.cmake
    "add_library(Platform.Interfaces INTERFACE)\n"
    "target_include_directories(Platform.Interfaces INTERFACE ${CURRENT_PACKAGES_DIR}/include/Platform.Interfaces)\n"
    "set_target_properties(Platform.Interfaces PROPERTIES CXX_STANDARD 20)\n"
    )

