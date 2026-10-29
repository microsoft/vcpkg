set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_nanotimer
    REF 84f93c76df71500689835897e8ad119c1aeb5e68
    SHA512 34c8a194c32b3745591965da2fa5a49332b46eeb6ecc0e1de7f149a687bc21dede8b0c4bb502228fcb4299de1af0c8381c95809a0365a69a63fd8bb0c6604bd7
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_nanotimer.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
