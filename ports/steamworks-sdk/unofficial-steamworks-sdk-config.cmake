if (NOT TARGET unofficial::steamworks-sdk::api)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(unofficial::steamworks-sdk::api UNKNOWN IMPORTED)

    find_path(STEAMWORKS_SDK_INCLUDE_DIR
        NAMES steam/steam_api.h
        DOC "The Steamworks SDK include directory"
    )

    find_library(VCPKG_STEAMWORKS_SDK_LIBRARY_RELEASE
        NAMES steam_api steam_api64
        PATHS "${_IMPORT_PREFIX}/lib"
        DOC "The Steamworks SDK library"
        REQUIRED
    )

    find_library(VCPKG_STEAMWORKS_SDK_LIBRARY_DEBUG
        NAMES steam_api steam_api64
        PATHS "${_IMPORT_PREFIX}/debug/lib"
        DOC "The Steamworks SDK debug library"
        REQUIRED
    )

    set_target_properties(unofficial::steamworks-sdk::api PROPERTIES
        IMPORTED_CONFIGURATIONS "Release;Debug"
        INTERFACE_INCLUDE_DIRECTORIES "${STEAMWORKS_SDK_INCLUDE_DIR}"
        IMPORTED_LOCATION_RELEASE "${VCPKG_STEAMWORKS_SDK_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${VCPKG_STEAMWORKS_SDK_LIBRARY_DEBUG}"
    )

    #####
    ## Feature: appticket
    #####
    find_library(VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_RELEASE
            NAMES sdkencryptedappticket sdkencryptedappticket64
            PATHS "${_IMPORT_PREFIX}/lib"
            DOC "The Steamworks SDK appticket library"
    )

    find_library(VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_DEBUG
            NAMES sdkencryptedappticket sdkencryptedappticket64
            PATHS "${_IMPORT_PREFIX}/debug/lib"
            DOC "The Steamworks SDK appticket debug library"
    )

    if(VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_RELEASE AND VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_DEBUG)
        add_library(unofficial::steamworks-sdk::appticket UNKNOWN IMPORTED)

        set_target_properties(unofficial::steamworks-sdk::appticket PROPERTIES
                IMPORTED_CONFIGURATIONS "Release;Debug"
                INTERFACE_INCLUDE_DIRECTORIES "${STEAMWORKS_SDK_INCLUDE_DIR}"
                IMPORTED_LOCATION_RELEASE "${VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_RELEASE}"
                IMPORTED_LOCATION_DEBUG "${VCPKG_STEAMWORKS_SDK_APPTICKET_LIBRARY_DEBUG}"
        )
    endif()
endif()