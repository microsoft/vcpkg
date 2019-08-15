include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dcleblanc/SafeInt
    REF 3.20.0
    SHA512 ebd10ac2578b4ab7968b2f89b7c8114a55bfd1967d625498a555b5354acf5a8c6b145b38429eb0dc853e7a0a33728a2a5acb505888bc983e7b0de81d09f50918
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/SafeInt.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/safeint RENAME copyright)
