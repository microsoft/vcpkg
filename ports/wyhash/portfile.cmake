vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO wangyi-fudan/wyhash
  REF a5995b98ebfa7bd38bfadc0919326d2e7aabb805
  SHA512 bf052e5f645af10c1fcee910f6afbcfdcd3c6b06a640f809ac112edd0ea2fe5ec00daacd9fe8489b310b5c6264c1fc69c68668331b3112b66b2cf0618ed18f47
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/wyhash.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
