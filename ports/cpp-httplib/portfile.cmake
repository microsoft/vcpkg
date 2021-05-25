# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF faa5f1d8023746a3da9f275c51867ded2a672ee9 # v0.8.6
    SHA512 87c34b4e6b311e47f568993319d82908c3e3a711b5b5ba15686e55e2588cea027e89a4d14666e61cddd8158bd9d1216e19f5be46cee13948e31bf6b4b0678bae
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
