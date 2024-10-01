# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_IS_MINGW
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md
set(VCPKG_LIBRARY_LINKAGE dynamic)

# Also consider vcpkg_from_* functions if you can; the generated code here is for any web accessable
# source archive.
#  vcpkg_from_github
#  vcpkg_from_gitlab
#  vcpkg_from_bitbucket
#  vcpkg_from_sourceforge
vcpkg_download_distfile(ARCHIVE
    URLS "https://partner.steamgames.com/downloads/steamworks_sdk_160.zip"
    FILENAME "steamworks_sdk_160.zip"
    SHA512 3fa8d579de1ddfc80cfab0e5cf3817a27be253251415cc2d5f97d675b6f27d53aebb69672fd7ffb76c0adff803228830a54848c394cebe2557240cf6a2ea08c1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at:
    # https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/examples/patching.md
    # PATCHES
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/win64/FindSteamworks-SDK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
        set(SDK_DESTINATION_PATH "${SOURCE_PATH}/redistributable_bin/win64/steam_api64")
        set(APP_TICKET_DESTINATION_PATH "${SOURCE_PATH}/public/steam/lib/win64/sdkencryptedappticket64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/win32/FindSteamworks-SDK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
        set(SDK_DESTINATION_PATH "${SOURCE_PATH}/redistributable_bin/steam_api")
        set(APP_TICKET_DESTINATION_PATH "${SOURCE_PATH}/public/steam/lib/win32/sdkencryptedappticket")
    endif()
    set(STEAMCMD_PATH "${SOURCE_PATH}/tools/ContentBuilder/builder")
    file(INSTALL "${SDK_DESTINATION_PATH}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SDK_DESTINATION_PATH}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${SDK_DESTINATION_PATH}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SDK_DESTINATION_PATH}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    if("appticket" IN_LIST FEATURES)
        file(INSTALL "${APP_TICKET_DESTINATION_PATH}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${APP_TICKET_DESTINATION_PATH}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(INSTALL "${APP_TICKET_DESTINATION_PATH}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${APP_TICKET_DESTINATION_PATH}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    set(VCPKG_FIXUP_MACHO_RPATH FALSE)
    set(STEAMCMD_PATH "${SOURCE_PATH}/tools/ContentBuilder/builder_osx")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/osx/FindSteamworks-SDK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(INSTALL "${SOURCE_PATH}/redistributable_bin/osx/libsteam_api.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/redistributable_bin/osx/libsteam_api.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    if("appticket" IN_LIST FEATURES)
        file(INSTALL "${SOURCE_PATH}/public/steam/lib/osx/libsdkencryptedappticket.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SOURCE_PATH}/public/steam/lib/osx/libsdkencryptedappticket.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    set(VCPKG_FIXUP_ELF_RPATH FALSE)
    set(STEAMCMD_PATH "${SOURCE_PATH}/tools/ContentBuilder/builder_linux")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/linux64/FindSteamworks-SDK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux64/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux64/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        if("appticket" IN_LIST FEATURES)
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux64/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux64/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/linux32/FindSteamworks-SDK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux32/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux32/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        if("appticket" IN_LIST FEATURES)
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux32/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux32/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()
endif()

file(COPY "${STEAMCMD_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY "${SOURCE_PATH}/public/steam" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# # Moves all .cmake files from /debug/share/steamworks/ to /share/steamworks/
# # See /docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md for more details
# When you uncomment "vcpkg_cmake_config_fixup()", you need to add the following to "dependencies" vcpkg.json:
#{
#    "name": "vcpkg-cmake-config",
#    "host": true
#}
# vcpkg_cmake_config_fixup()

# Uncomment the line below if necessary to install the license file for the port
# as a file named `copyright` to the directory `${CURRENT_PACKAGES_DIR}/share/${PORT}`
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Readme.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")