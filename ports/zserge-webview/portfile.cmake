# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webview/webview
    REF 2ee04ccd0530e3928a872f5d508c114403803e61 #commit-2022-09-07
    SHA512 c784635a0c0948d91fea12643b04f0125e0be64d34aeddafbd0240aa977e867fa74efaf4e5dea7fe207bc0d1461b544f483d6228bf92dade7dc0d5e2c5a585a6
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
