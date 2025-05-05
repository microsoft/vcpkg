set(GDK_EDITION_NUMBER 241002)

# The GDK contains a combination of static C++ libraries and DLL-based extension libraries.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.PC/${VERSION}"
    FILENAME "ms-gdk.${VERSION}.zip"
    SHA512 e9b40b1c904e1a082b0078f6d3654fad7f859f9676b169f2e2223b74b5d2546c69bd79c365d6f4b915fbe6a2afc1b664d2ce47c902b7fb59f9a038fe2a060f99
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        playfab BUILD_PLAYFAB_SERVICES
)

set(GRDK_PATH "${PACKAGE_PATH}/native/${GDK_EDITION_NUMBER}/GRDK")

# We use the gameinput port instead
file(REMOVE "${GRDK_PATH}/GameKit/Include/GameInput.h")
file(REMOVE "${GRDK_PATH}/GameKit/Lib/amd64/GameInput.lib")

vcpkg_cmake_configure(
    SOURCE_PATH "${GRDK_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.gameruntime)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.game.chat.2.cpp.api)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.libhttpclient)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.services.api.c)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.xcurl.api)

set(LICENSE_FILES "${PACKAGE_PATH}/LICENSE.md")

list(APPEND LICENSE_FILES
    "${GRDK_PATH}/ExtensionLibraries/Xbox.LibHttpClient/Include/httpClient/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.XCurl.API/Include/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/cpprest/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/pplx/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/xsapi-c/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/xsapi-cpp/ThirdPartyNotices.txt"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if("playfab" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.multiplayer.cpp)
    vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.party.cpp)
    vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.partyxboxlive.cpp)
    vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.services.c)

    list(APPEND LICENSE_FILES
        "${GRDK_PATH}/ExtensionLibraries/PlayFab.Multiplayer.Cpp/Include/NOTICE.txt"
        "${GRDK_PATH}/ExtensionLibraries/PlayFab.Party.Cpp/Include/NOTICE.txt"
        "${GRDK_PATH}/ExtensionLibraries/PlayFab.PartyXboxLive.Cpp/Include/NOTICE.txt"
    )

    file(READ "${CMAKE_CURRENT_LIST_DIR}/pfusage" USAGE_CONTENT)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" ${USAGE_CONTENT})
else()
endif()

file(INSTALL "${PACKAGE_PATH}/native/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
file(INSTALL "${PACKAGE_PATH}/native/bin/GameConfigEditorDependencies" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
