if(VCPKG_TARGET_IS_UWP)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(VERSION 1.0.1210.39)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/${VERSION}"
    FILENAME "microsoft.web.webview2.${VERSION}.zip"
    SHA512 c87812247a466f4aaeac8be8b32be49166b4ddb5bbf65581d5df81d69eda340e9911144a8dd8401baa6e51f95337001cd18ff90cd36ca0af86cc65227e8e2ccf
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${VERSION}"
    NO_REMOVE_ONE_LEVEL
)

file(COPY
    "${SOURCE_PATH}/build/native/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY
        "${SOURCE_PATH}/build/native/${VCPKG_TARGET_ARCHITECTURE}/WebView2LoaderStatic.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(COPY
        "${SOURCE_PATH}/build/native/include-winrt/"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(COPY
        "${SOURCE_PATH}/lib/Microsoft.Web.WebView2.Core.winmd"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY
        "${SOURCE_PATH}/build/native/${VCPKG_TARGET_ARCHITECTURE}/WebView2Loader.dll.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY
        "${SOURCE_PATH}/build/native/${VCPKG_TARGET_ARCHITECTURE}/WebView2Loader.dll"
        "${SOURCE_PATH}/runtimes/win-${VCPKG_TARGET_ARCHITECTURE}/native_uap/Microsoft.Web.WebView2.Core.dll"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(COPY "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
    endif()
    file(COPY "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-webview2-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-webview2")

# The import libraries for webview fail with "Could not find proper second linker member"
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
