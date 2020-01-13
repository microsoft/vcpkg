include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/lest
    REF v1.35.1
    SHA512 06b786cbca37cb4d20737d040176bf34398090d566310b88558b788804d8b832c682f1814f5c68ef11192243dbde5643e73b78be4fb1407b831bcde43adb002c
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/lest RENAME copyright)
