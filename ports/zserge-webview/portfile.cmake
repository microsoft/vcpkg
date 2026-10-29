# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webview/webview
    REF ${VERSION}
    SHA512 f198e414145101693fd2b5724fb017df578770c6edda319ce312cf9e9e1fdc1b1d94beba2e64e75d9746dee16010cc525be8ae7ca0713ee541b75a0a1d9bc791
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/core/include/webview.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
