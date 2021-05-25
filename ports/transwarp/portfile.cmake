vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomen/transwarp
    REF 2.2.2
    SHA512 32e5dce698bff565f98ac73e7a4213858f5024003f01d798a6f7eb99289f192dd56b45c975c0e42be36e28e0b828c9810f5d27e62312649606b78ec93e4afae4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
