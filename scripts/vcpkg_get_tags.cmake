function(vcpkg_get_tags PORT FEATURES VCPKG_TRIPLET_FILE VCPKG_ABI_SETTINGS_FILE)
    message("d8187afd-ea4a-4fc3-9aa4-a6782e1ed9af")
    include(${VCPKG_TRIPLET_FILE})

    # GUID used as a flag - "cut here line"
    message("c35112b6-d1ba-415b-aa5d-81de856ef8eb")
    message("VCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}")
    message("VCPKG_CMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
    message("VCPKG_CMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    message("VCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}")
    message("VCPKG_VISUAL_STUDIO_PATH=${VCPKG_VISUAL_STUDIO_PATH}")
    message("VCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    message("VCPKG_BUILD_TYPE=${VCPKG_BUILD_TYPE}")
    message("e1e74b5c-18cb-4474-a6bd-5c1c8bc81f3f")

    # Just to enforce the user didn't set it in the triplet file
    if (DEFINED VCPKG_PUBLIC_ABI_OVERRIDE)
        set(VCPKG_PUBLIC_ABI_OVERRIDE)
        message(WARNING "VCPKG_PUBLIC_ABI_OVERRIDE set in the triplet will be ignored.")
    endif()
    include("${VCPKG_ABI_SETTINGS_FILE}" OPTIONAL)

    message("c35112b6-d1ba-415b-aa5d-81de856ef8eb")
    message("VCPKG_PUBLIC_ABI_OVERRIDE=${VCPKG_PUBLIC_ABI_OVERRIDE}")
    message("VCPKG_ENV_PASSTHROUGH=${VCPKG_ENV_PASSTHROUGH}")
    message("e1e74b5c-18cb-4474-a6bd-5c1c8bc81f3f")
    message("8c504940-be29-4cba-9f8f-6cd83e9d87b7")
endfunction()
