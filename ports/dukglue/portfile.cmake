vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Aloshi/dukglue
    REF c3ec2a463a03a4fa34715aa75273537d39900edb #2022-11-08
    HEAD_REF master
    SHA512 60bf0274113fa7d547ed2890268782176c507ab0b7ea601362640bb2d4d637ce013a4dabeffbd8a82ed672b2de7778355b6e79642d70cfc2c1f1cf2c2fd9f6c1
)

file(COPY "${SOURCE_PATH}/include/dukglue" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
