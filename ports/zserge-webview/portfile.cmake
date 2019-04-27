# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zserge/webview
    REF 16c93bcaeaeb6aa7bb5a1432de3bef0b9ecc44f3
    SHA512 153824bd444eafe6cc5ae00800422b41d4047dc85a164c465990c3be06d82003b532e1e869bb40e3a77cbe4789ff970fcda50ef00ac7b3e2f22ef3f566340026
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/webview.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/include/webview.h
    "#ifdef WEBVIEW_STATIC"
    "#if 1 // #ifdef WEBVIEW_STATIC"
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/include/webview.h
    "#ifdef WEBVIEW_IMPLEMENTATION"
    "#if 1 // #ifdef WEBVIEW_IMPLEMENTATION"
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
