if(VCPKG_TARGET_IS_UWP)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/${VERSION}"
    FILENAME "microsoft.web.webview2.${VERSION}.zip"
    SHA512 70e6a256a3f7066407327c46a59cc034cdb6b545e0c9cae2b322478c818dcc868cb26f225e3ecac7e71e620f916d8c09b734f4d3da9f7054e872f54b63e7a433
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
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
