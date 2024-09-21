# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webview/webview
    REF 8387ff8945fc010e7c4203c021943ce4ca12a276 #commit-2023-04-15
    SHA512 def8d4d5322546a0d3a767f76a6024c0c09e0da184445836f9c1887ab5bdfa1276fb8f2ed65b1b366c237cb22e935b1c6dd99151417c652cd3c5881255494f69
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/webview.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(WEBVIEW_GTK "0")
set(WEBVIEW_EDGE "0")
set(WEBVIEW_COCOA "0")

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(WEBVIEW_EDGE "1")
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(WEBVIEW_COCOA "1")
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(WEBVIEW_GTK "1")
endif()

file(READ "${CURRENT_PACKAGES_DIR}/include/webview.h" _contents)
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
file(WRITE "${CURRENT_PACKAGES_DIR}/include/webview.h" "${_contents}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
