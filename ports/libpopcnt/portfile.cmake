set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kimwalisch/libpopcnt
    REF "v${VERSION}"
    SHA512 b01f1446c951b848357ed01e31cb2d1014639ba854710edcc5703b69226b9ca2e65c84d78308cf345654fbfc92ce467bb5a5171158db5b94f979674efb59f6dc
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/libpopcnt.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
