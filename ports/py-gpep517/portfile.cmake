vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projg2/gpep517
    REF v${VERSION}
    SHA512 7c3b878220e907ef801301eadc0e3031dd3c31770cc50bb7119ab32f9244c8a33792b4896ddeffc5d4b7be9f1d881fba5179de155f11845f510e455be59fb92e
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/gpep517" DESTINATION "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")
# TODO: python3 -m compileall "$pkgdir/$sitedir"

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
