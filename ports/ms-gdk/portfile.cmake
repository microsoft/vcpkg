set(GDK_EDITION_NUMBER 241000)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.PC/${VERSION}"
    FILENAME "ms-gdk.${VERSION}.zip"
    SHA512 a3ff91cb033a33e971db0b25285f665c80f3e5b97cd5e1b1859ed0a9b3da77285359665a9d0a7f3b5473ac094ed7351c3e6534c656cc5e54daf69af0890ba3e8
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

set(GRDK_PATH "${PACKAGE_PATH}/native/${GDK_EDITION_NUMBER}/GRDK")

vcpkg_cmake_configure(
    SOURCE_PATH ${GRDK_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.gameruntime)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.game.chat.2.cpp.api)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.libhttpclient)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.services.api.c)
vcpkg_cmake_config_fixup(PACKAGE_NAME xbox.xcurl.api)

vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.multiplayer.cpp)
vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.party.cpp)
vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.partyxboxlive.cpp)
vcpkg_cmake_config_fixup(PACKAGE_NAME playfab.services.c)

file(INSTALL "${PACKAGE_PATH}/native/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
file(INSTALL "${PACKAGE_PATH}/native/bin/GameConfigEditorDependencies" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/debug/lib/Microsoft.Xbox.Services.142.GDK.C.lib"
    "${CURRENT_PACKAGES_DIR}/debug/lib/Microsoft.Xbox.Services.142.GDK.C.pdb"
    "${CURRENT_PACKAGES_DIR}/debug/lib/Microsoft.Xbox.Services.GDK.C.Thunks.lib"
    "${CURRENT_PACKAGES_DIR}/debug/lib/Microsoft.Xbox.Services.GDK.C.Thunks.pdb"
    )

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/lib/Microsoft.Xbox.Services.142.GDK.C.debug.lib"
    "${CURRENT_PACKAGES_DIR}/lib/Microsoft.Xbox.Services.142.GDK.C.debug.pdb"
    "${CURRENT_PACKAGES_DIR}/lib/Microsoft.Xbox.Services.GDK.C.Thunks.debug.lib"
    "${CURRENT_PACKAGES_DIR}/lib/Microsoft.Xbox.Services.GDK.C.Thunks.debug.pdb"
    )

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST
    "${PACKAGE_PATH}/LICENSE.md"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.LibHttpClient/Include/httpClient/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.XCurl.API/Include/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/cpprest/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/pplx/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/xsapi-c/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/Xbox.Services.API.C/Include/xsapi-cpp/ThirdPartyNotices.txt"
    "${GRDK_PATH}/ExtensionLibraries/PlayFab.Multiplayer.Cpp/Include/NOTICE.txt"
    "${GRDK_PATH}/ExtensionLibraries/PlayFab.Party.Cpp/Include/NOTICE.txt"
    "${GRDK_PATH}/ExtensionLibraries/PlayFab.PartyXboxLive.Cpp/Include/NOTICE.txt"
)
