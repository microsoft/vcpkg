vcpkg_download_distfile(ARCHIVE
    URLS "https://partner.steamgames.com/downloads/steamworks_sdk_160.zip"
    FILENAME "steamworks_sdk_160.zip"
    SKIP_SHA512 # Not sure why, but the SHA512 hash is changing with each download
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(SDK_DESTINATION_PATH "${SOURCE_PATH}/redistributable_bin/win64/steam_api64")
        set(APP_TICKET_DESTINATION_PATH "${SOURCE_PATH}/public/steam/lib/win64/sdkencryptedappticket64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
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
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux64/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SOURCE_PATH}/redistributable_bin/linux64/libsteam_api.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        if("appticket" IN_LIST FEATURES)
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux64/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${SOURCE_PATH}/public/steam/lib/linux64/libsdkencryptedappticket.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-steamworks-sdk-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-steamworks-sdk")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Readme.txt")