set(z_vcpkg_icu_fixup "")
set(z_vcpkg_icu_config_mode_args "${ARGS}")
list(FILTER z_vcpkg_icu_config_mode_args INCLUDE REGEX "^(CONFIGS?|HINTS|NAMES|NO_MODULE|PATH_SUFFIXES|PATHS)\$")
if(z_vcpkg_icu_config_mode_args STREQUAL "")
    cmake_policy(PUSH)
    cmake_policy(SET CMP0057 NEW)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        # Fix problem: Static link libraries, ordered for traditional linker
        if("io" IN_LIST ARGS AND NOT TARGET ICU::io)
            if("in" IN_LIST ARGS)
                list(APPEND z_vcpkg_icu_fixup "io->in")
                list(REMOVE_ITEM ARGS in)
                list(APPEND ARGS COMPONENTS in)
            else()
                list(APPEND z_vcpkg_icu_fixup "io->i18n")
                list(REMOVE_ITEM ARGS i18n)
                list(APPEND ARGS COMPONENTS i18n)
            endif()
        endif()
        if("i18n" IN_LIST ARGS AND NOT TARGET ICU::i18n)
            list(APPEND z_vcpkg_icu_fixup "i18n->uc")
            list(REMOVE_ITEM ARGS uc)
            list(APPEND ARGS COMPONENTS uc)
        endif()
        if("in" IN_LIST ARGS AND NOT TARGET ICU::in)
            list(APPEND z_vcpkg_icu_fixup "in->uc")
            list(REMOVE_ITEM ARGS uc)
            list(APPEND ARGS COMPONENTS uc)
        endif()
        if("uc" IN_LIST ARGS AND NOT TARGET ICU::uc)
            if("dt" IN_LIST ARGS)
                list(APPEND z_vcpkg_icu_fixup "uc->dt")
                list(REMOVE_ITEM ARGS dt)
                list(APPEND ARGS COMPONENTS dt)
            else()
                list(APPEND z_vcpkg_icu_fixup "uc->data")
                list(REMOVE_ITEM ARGS data)
                list(APPEND ARGS COMPONENTS data)
            endif()
            # Fix problem: C++ linkage
            add_library(ICU::uc STATIC IMPORTED)
            list(APPEND z_vcpkg_icu_fixup "uc->c++")
        endif()
    endif()
    # Fix problem: Find debug variant without 'd' suffix
    # Fix problem: Apply NAMES_PER_DIR
    if("data" IN_LIST ARGS)
        find_library(ICU_DATA_LIBRARY_RELEASE NAMES icudata icudt NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_DATA_LIBRARY_DEBUG NAMES icudatad icudtd icudata icudt NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("dt" IN_LIST ARGS)
        find_library(ICU_DT_LIBRARY_RELEASE NAMES icudata icudt NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_DT_LIBRARY_DEBUG NAMES icudatad icudtd icudata icudt NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("i18n" IN_LIST ARGS)
        find_library(ICU_I18N_LIBRARY_RELEASE NAMES icui18n icuin NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_I18N_LIBRARY_DEBUG NAMES icui18nd icuind icui18n icuin NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("in" IN_LIST ARGS)
        find_library(ICU_IN_LIBRARY_RELEASE NAMES icui18n icuin NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_IN_LIBRARY_DEBUG NAMES icui18nd icuind icui18n icuin NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("io" IN_LIST ARGS)
        find_library(ICU_IO_LIBRARY_RELEASE NAMES icuio NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_IO_LIBRARY_DEBUG NAMES icuiod icuio NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("tu" IN_LIST ARGS)
        # optional, subject to icu[tools].
        find_library(ICU_TU_LIBRARY_RELEASE NAMES icutu NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
        find_library(ICU_TU_LIBRARY_DEBUG NAMES icutud icutu NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    if("uc" IN_LIST ARGS)
        find_library(ICU_UC_LIBRARY_RELEASE NAMES icuuc NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(ICU_UC_LIBRARY_DEBUG NAMES icuucd icuuc NAMES_PER_DIR PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    endif()
    cmake_policy(POP)
endif()

_find_package(${ARGS})

if(ICU_FOUND AND NOT z_vcpkg_icu_fixup STREQUAL "")
    cmake_policy(PUSH)
    cmake_policy(SET CMP0057 NEW)
    if("uc->c++" IN_LIST z_vcpkg_icu_fixup)
        list(REMOVE_ITEM z_vcpkg_icu_fixup "uc->c++")
        if(ICU_INCLUDE_DIR)
          set_target_properties(ICU::uc PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${ICU_INCLUDE_DIR}")
        endif()
        if(EXISTS "${ICU_UC_LIBRARY}")
          set_target_properties(ICU::uc PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
            IMPORTED_LOCATION "${ICU_UC_LIBRARY}")
        endif()
        if(EXISTS "${ICU_UC_LIBRARY_RELEASE}")
          set_property(TARGET ICU::uc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE)
          set_target_properties(ICU::uc PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
            IMPORTED_LOCATION_RELEASE "${ICU_UC_LIBRARY_RELEASE}")
        endif()
        if(EXISTS "${ICU_UC_LIBRARY_DEBUG}")
          set_property(TARGET ICU::uc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG)
          set_target_properties(ICU::uc PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
            IMPORTED_LOCATION_DEBUG "${ICU_UC_LIBRARY_DEBUG}")
        endif()
    endif()
    if("i18n->uc" IN_LIST z_vcpkg_icu_fixup)
        list(REMOVE_ITEM z_vcpkg_icu_fixup "i18n->uc")
        set_target_properties(ICU::i18n PROPERTIES INTERFACE_LINK_LIBRARIES ICU::uc)
    endif()
    if("in->uc" IN_LIST z_vcpkg_icu_fixup)
        list(REMOVE_ITEM z_vcpkg_icu_fixup "in->uc")
        set_target_properties(ICU::in PROPERTIES INTERFACE_LINK_LIBRARIES ICU::uc)
    endif()
    if("uc->data" IN_LIST z_vcpkg_icu_fixup)
        list(REMOVE_ITEM z_vcpkg_icu_fixup "uc->data")
        set_target_properties(ICU::uc PROPERTIES INTERFACE_LINK_LIBRARIES ICU::data)
    endif()
    if("uc->dt" IN_LIST z_vcpkg_icu_fixup)
        list(REMOVE_ITEM z_vcpkg_icu_fixup "uc->dt")
        set_target_properties(ICU::uc PROPERTIES INTERFACE_LINK_LIBRARIES ICU::dt)
    endif()
    if(NOT z_vcpkg_icu_fixup STREQUAL "")
        message(WARNING "Missing fixup handler for ${z_vcpkg_icu_fixup}.")
    endif()
    cmake_policy(POP)
endif()

if(TARGET ICU::uc)
    target_compile_features(ICU::uc INTERFACE cxx_std_17)
endif()

if("windowssystem" IN_LIST FEATURES)
    # 1. Clear out any cached variables to prevent accidental lookups
    unset(ICU_FOUND CACHE)
    
    # 2. Leverage Windows SDK environment paths
    if(DEFINED ENV{WindowsSDKDir} AND DEFINED ENV{WindowsSDKVersion})
        set(WindowsSDK_UM_Include "$ENV{WindowsSDKDir}Include/$ENV{WindowsSDKVersion}um")
    else()
        # Fallback if environment variables are missing from the current shell context
        set(WindowsSDK_UM_Include "C:/Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/um")
    endif()

    # 3. Explicitly map targets to system library binaries
    set(ICU_INCLUDE_DIRS "${WindowsSDK_UM_Include}" CACHE PATH "Windows SDK ICU Include Dir" FORCE)
    set(ICU_INCLUDE_DIR "${WindowsSDK_UM_Include}" CACHE PATH "Windows SDK ICU Include Dir" FORCE)
    
    # Windows native ICU exports a unified icu.lib import library for icu.dll
    find_library(ICU_SYSTEM_LIB NAMES icu PATHS "$ENV{WindowsSDKDir}Lib/$ENV{WindowsSDKVersion}um/$ENV{VCPKG_TARGET_ARCHITECTURE}" REQUIRED)
    
    set(ICU_LIBRARIES "${ICU_SYSTEM_LIB}" CACHE STRING "Windows Native ICU Lib" FORCE)
    set(ICU_FOUND TRUE CACHE BOOL "Windows Native ICU Found" FORCE)
    
    # 4. Generate the standard modern CMake imported targets expected by downstream ports
    if(NOT TARGET ICU::icu)
        add_library(ICU::icu INTERFACE IMPORTED)
        set_target_properties(ICU::icu PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${ICU_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${ICU_LIBRARIES}"
        )
        # Map common aliases that downstream CMake scripts look for
        add_library(ICU::uc ALIAS ICU::icu)
        add_library(ICU::i18n ALIAS ICU::icu)
        add_library(ICU::data ALIAS ICU::icu)
    endif()

    # Skip running standard find_package logic
    set(ICU_FIND_QUIETLY TRUE)
else()
    # Call the original underlying find path for a compiled ICU port
    _find_package(${ARGS})
endif()
