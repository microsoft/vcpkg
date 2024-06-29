vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projg2/gpep517
    REF v${VERSION}
    SHA512 fcd7cb0f98003a8ecb9976cffe3d4140b16e537dbfcfa8e8416569cd7e38e8e9ab359b35c1e22b830dc2711b3c07f8e3113c0f6b73d415ce63ad5f7d76f180c6
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/gpep517" DESTINATION "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")
# TODO: python3 -m compileall "$pkgdir/$sitedir"

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

#vcpkg_python_test_import(MODULE "gpep517")
