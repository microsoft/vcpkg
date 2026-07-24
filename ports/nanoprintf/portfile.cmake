# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 725109f10e41b2c7a3dd0b03cc0f71028246ca1e9a85e7bf6737baaaacbf47655e0d2a659b2fe2bac9166ba3118c7cb7473fdcfc8f3b8027df355ffd8f0775af
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
