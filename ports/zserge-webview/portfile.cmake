# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zserge/webview
    REF 16c93bcaeaeb6aa7bb5a1432de3bef0b9ecc44f3
    SHA512 153824bd444eafe6cc5ae00800422b41d4047dc85a164c465990c3be06d82003b532e1e869bb40e3a77cbe4789ff970fcda50ef00ac7b3e2f22ef3f566340026
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/webview.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

set(WEBVIEW_GTK "0")
set(WEBVIEW_WINAPI "0")
set(WEBVIEW_COCOA "0")

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(WEBVIEW_WINAPI "1")
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(WEBVIEW_COCOA "1")
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(WEBVIEW_GTK "1")
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/webview.h _contents)
string(REPLACE
    "#ifdef WEBVIEW_STATIC"
    "#if 1 // #ifdef WEBVIEW_STATIC"
    _contents "${_contents}"
)
string(REPLACE
    "#ifdef WEBVIEW_IMPLEMENTATION"
    "#if 1 // #ifdef WEBVIEW_IMPLEMENTATION"
    _contents "${_contents}"
)
string(REPLACE
    "defined(WEBVIEW_GTK)"
    "${WEBVIEW_GTK} // defined(WEBVIEW_GTK)"
    _contents "${_contents}"
)
string(REPLACE
    "defined(WEBVIEW_WINAPI)"
    "${WEBVIEW_WINAPI} // defined(WEBVIEW_WINAPI)"
    _contents "${_contents}"
)
string(REPLACE
    "defined(WEBVIEW_COCOA)"
    "${WEBVIEW_COCOA} // defined(WEBVIEW_COCOA)"
    _contents "${_contents}"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/include/webview.h "${_contents}")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
