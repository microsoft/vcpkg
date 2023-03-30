vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/x86-simd-sort
    REF 7d7591cf5927e83e4a1e7c4b6f2c4dc91a97889f
    SHA512 6b71f25e0ec1adcd81a6ce3ecf60316a841c48d9b438ae2afde9b2a17a90d13047cb1d7bce7dcecf15718f4fb299adad7875b022b57f90965f5e7a25e16e6721
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
