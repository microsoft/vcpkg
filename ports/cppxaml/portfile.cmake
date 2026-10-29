#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asklar/xaml-islands
    REF 0.0.16
    SHA512 30fba1ef9264bf2eeaf0e48898c6b138adef9ee98d758ac91bcc7f2c90e50f00ec35925705347c3fc5c84b97652caeece7b3854be5b468a02e51fed23eda8007
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/inc/cppxaml" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
