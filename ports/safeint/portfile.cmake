include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dcleblanc/SafeInt
    REF b1c48bd32b5e748ed57c153c418a5ed67538045a
    SHA512 d0b59430da353e0af55a9ab83964e35bfb61edff00f8a2aef6df139720f271aae851ea9de54ca4280e220eff9946590a7b5c85c102f3c2e5f051a6cb7d7a3e5e
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/SafeInt.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/safeint RENAME copyright)
