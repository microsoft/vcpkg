set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lunarmodules/lua-compat-5.3
    REF "v${VERSION}"
    SHA512 6b17213321a08268228a97180e08289b85d6554b25cac89f7b7f72e79be0169af233fade87718b4a68485e0357dcb34245e660222e5c9d06254b0f3b64ef19cd
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/c-api/compat-5.3.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/c-api/compat-5.3.c" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
