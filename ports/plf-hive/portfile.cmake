# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_hive
    REF 39dfcc5712125cc645df123c120006b7a6fd95d6
    SHA512 81a1f185ca8293b6fb83605c05ecf14d024194334cb64932daa29ecae064918241fa7f3e4a688dc2b19b4b5dd8a2605d60947bd513f7cd30299fd6ba25aa8b35
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_hive.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
