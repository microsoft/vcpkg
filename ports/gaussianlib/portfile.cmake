# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/GaussianLib
    REF da580773dc65eefb4369894587864384e5e0dd7e # 2024-11-03
    SHA512 4092c9d69c15e4aca08bde140dde2e7fa919dad4cb4f9138871efd9d23cd3d672201bc65608b8a379186e5d64b14e10852323a4a243c5ccd9911b7b9589cd927
    HEAD_REF master
)


file(COPY "${SOURCE_PATH}/include/Gauss" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
