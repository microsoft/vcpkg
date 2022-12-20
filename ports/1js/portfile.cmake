vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skyrim-multiplayer/skymp
    REF de0cd797248df7ae3f252e4cf703401d5609feff
    SHA512 0
    HEAD_REF main
)

file(INSTALL ${SOURCE_PATH}/1js/JsEngine.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/1js/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/1js RENAME copyright)