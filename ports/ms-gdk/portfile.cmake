set(GDK_EDITION_NUMBER 260403)

# The GDK contains a combination of static C++ libraries and DLL-based extension libraries.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE_CORE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.Core/${VERSION}"
    FILENAME "ms-gdk-core.${VERSION}.zip"
    SHA512 9c607f4bed88a53aafde4f56c89fc02f0b7bfd7006f793aeeea77aceb0ccefbe7dbf4874b6414ead4e26c78599236476c3432150eed78576b684e6219e075fd7
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GDK.Windows/${VERSION}"
    FILENAME "ms-gdk-windows.${VERSION}.zip"
    SHA512 bd6951bc05c2010f35a2f2565bb42a4306c9962309810bfa82379d689d5095f483e11f590c226e7bf8847fa1b868d8f44b75abf707feee00944dc9db5b98113c
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

# Install core content
set(CORE_BINS xgameruntime.dll xgameruntime.thunks.dll GameChat2.dll libHttpClient.dll XCurl.dll)
set(CORE_INCLUDES grdk.h cpprestsdk_impl.h XCurl.h GameChat2.h GameChat2Impl.h GameChat2_c.h)
set(CORE_LIBS xgameruntime.lib GameChat2.lib libHttpClient.lib XCurl.lib xgameruntime.thunks.lib)

file(GLOB HEADERS "${WINDOWS_PATH}/include/X*.*")
foreach(t IN LISTS HEADERS)
    get_filename_component(h ${t} NAME)
    list(APPEND CORE_INCLUDES ${h})
endforeach()

set(INCLUDE_DIRS httpClient Xal xsapi-c xsapi-cpp)

file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.C.Thunks.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.C.Thunks.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.143.C.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.143.C.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${WINDOWS_PATH}/bin/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.C.Thunks.Debug.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.C.Thunks.Debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.143.C.Debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "${WINDOWS_PATH}/lib/${VCPKG_TARGET_ARCHITECTURE}/Microsoft.Xbox.Services.143.C.Debug.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

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

    set(PF_BINS
        PlayFabCore.dll PlayFabServices.dll PlayFabMultiplayer.dll
        Party.dll PartyXboxLive.dll PlayFabGameSave.dll)

    set(PF_LIBS
        PlayFabCore.lib PlayFabServices.lib PlayFabMultiplayer.lib
        Party.lib PartyXboxLive.lib PlayFabGameSave.lib)

    file(INSTALL "${WINDOWS_PATH}/include/playfab" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${WINDOWS_PATH}/include/PFXGameSave.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

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

set(EXT_TOOLSET 143)
configure_file("${CMAKE_CURRENT_LIST_DIR}/gdk-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    @ONLY)

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

message(STATUS "BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS: https://www.nuget.org/packages/Microsoft.GDK.Windows/${VERSION}/License")
