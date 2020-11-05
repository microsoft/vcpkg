vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/IF97
    REF v2.1.2
    SHA512 a7625fcc1ca0763df5b4cf5be741babbaefc09022940b4fc5ee1c05121751282c18ebd87ae58e1eee9bdb46dab5ae6fb4ed9a31fc2c53dc6de5cbd243fa4c8e9
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/IF97.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/if97
  RENAME copyright
)
