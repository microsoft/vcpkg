set(GDK_EDITION_NUMBER 251001)

# The GDK contains a combination of static C++ libraries and DLL-based extension libraries.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE_CORE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.Core/${VERSION}"
    FILENAME "ms-gdk-core.${VERSION}.zip"
    SHA512 51315daea46c9d5ca2198b147566deea6def620c967e82968b95826d115c9e4ad4c495ef5ff29efe30df97df6802bcc4747120954b8dd66f99e91899caf0d3ce
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.Windows/${VERSION}"
    FILENAME "ms-gdk-windows.${VERSION}.zip"
    SHA512 18694435fcbc34093e2e4d22f535f7f116f20bf771b7f7c9b4a9b67b7047a2214b86afc112d9006da936df6070eded9f0b9aeb773442097b7e6b4615f99d6f44
)

vcpkg_extract_source_archive(
    PACKAGE_PATH_CORE
    ARCHIVE "${ARCHIVE_CORE}"
    NO_REMOVE_ONE_LEVEL
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

# Install core tools
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    file(INSTALL "${PACKAGE_PATH_CORE}/native/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
    file(INSTALL "${PACKAGE_PATH_CORE}/native/bin/GameConfigEditorDependencies" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
endif()

set(WINDOWS_PATH "${PACKAGE_PATH}/native/${GDK_EDITION_NUMBER}/windows")

# We use the gameinput port instead
file(REMOVE "${WINDOWS_PATH}/include/GameInput.h")
file(REMOVE "${WINDOWS_PATH}/lib/arm64/GameInput.lib")
file(REMOVE "${WINDOWS_PATH}/lib/x64/GameInput.lib")

# We use the cpprestsdk port instead
file(REMOVE_RECURSE "${WINDOWS_PATH}/include/cpprest")
file(REMOVE_RECURSE "${WINDOWS_PATH}/include/pplx")

# Install core content
set(CORE_BINS xgameruntime.dll xgameruntime.pdb)
set(CORE_INCLUDES grdk.h)
set(CORE_LIBS xgameruntime.lib)

file(GLOB HEADERS "${WINDOWS_PATH}/include/X*.*")
foreach(t IN LISTS HEADERS)
    get_filename_component(h ${t} NAME)
    list(APPEND CORE_INCLUDES ${h})
endforeach()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND CORE_BINS xgameruntime.thunks.dll GameChat2.dll GameChat2.pdb libHttpClient.dll libHttpClient.pdb XCurl.dll XCurl.pdb)
    list(APPEND CORE_LIBS GameChat2.lib libHttpClient.lib XCurl.lib xgameruntime.thunks.lib)

    file(INSTALL "${WINDOWS_PATH}/bin/x64/Microsoft.Xbox.Services.C.Thunks.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${WINDOWS_PATH}/bin/x64/Microsoft.Xbox.Services.C.Thunks.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.C.Thunks.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.142.C.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.142.C.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    file(INSTALL "${WINDOWS_PATH}/bin/x64/Microsoft.Xbox.Services.C.Thunks.Debug.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${WINDOWS_PATH}/bin/x64/Microsoft.Xbox.Services.C.Thunks.Debug.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.C.Thunks.Debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.142.C.Debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${WINDOWS_PATH}/lib/x64/Microsoft.Xbox.Services.142.C.Debug.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    list(APPEND CORE_INCLUDES cpprestsdk_impl.h XCurl.h GameChat2.h GameChat2Impl.h GameChat2_c.h)

    set(INCLUDE_DIRS httpClient Xal xsapi-c xsapi-cpp)
endif()

foreach(t IN LISTS CORE_BINS)
    file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endforeach()

foreach(t IN LISTS CORE_INCLUDES)
    file(INSTALL "${WINDOWS_PATH}/include/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

foreach(t IN LISTS INCLUDE_DIRS)
    file(INSTALL "${WINDOWS_PATH}/include/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

foreach(t IN LISTS CORE_LIBS)
    file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endforeach()

# Build license file.
set(LICENSE_FILES "${PACKAGE_PATH}/LICENSE.md")

list(APPEND LICENSE_FILES
    "${WINDOWS_PATH}/include/httpClient/ThirdPartyNotices.txt"
    "${WINDOWS_PATH}/include/ThirdPartyNotices.txt"
    "${WINDOWS_PATH}/include/xsapi-c/ThirdPartyNotices.txt"
    "${WINDOWS_PATH}/include/xsapi-cpp/ThirdPartyNotices.txt"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Optional PlayFab components
if("playfab" IN_LIST FEATURES)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PF_BINS
            PlayFabCore.dll PlayFabCore.pdb PlayFabServices.dll PlayFabServices.pdb PlayFabMultiplayer.dll PlayFabMultiplayer.pdb
            Party.dll Party.pdb PartyXboxLive.dll PartyXboxLive.pdb PlayFabGameSave.dll PlayFabGameSave.pdb)

        set(PF_LIBS
            PlayFabCore.lib PlayFabServices.lib PlayFabMultiplayer.lib
            Party.lib PartyXboxLive.lib PlayFabGameSave.lib)

        file(INSTALL "${WINDOWS_PATH}/include/playfab" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
        file(INSTALL "${WINDOWS_PATH}/include/PFXGameSave.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    endif()

    foreach(t IN LISTS PF_BINS)
        file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endforeach()

    foreach(t IN LISTS PF_LIBS)
        file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/${t}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endforeach()

    list(APPEND LICENSE_FILES "${WINDOWS_PATH}/include/playfab/multiplayer/NOTICE.txt")

    file(READ "${CMAKE_CURRENT_LIST_DIR}/pfusage" USAGE_CONTENT)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" ${USAGE_CONTENT})

endif()

set(EXT_TOOLSET 142)
configure_file("${CMAKE_CURRENT_LIST_DIR}/gdk-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    @ONLY)

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

message(STATUS "BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS: https://www.nuget.org/packages/Microsoft.GDK.Windows/${VERSION}/License")
