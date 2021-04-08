# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF cf475bcb505678046d53f0e0575a9efaa5b227f9 # v0.8.4
    SHA512 fbfb2294aaf50dc2eb053b89a4640ac2928268f936666a4c84724f5dc021fbfc30b3b451e213f4697f3d46bf87c078ccb01e8c2326153e3241bbd81fcf74427d
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
