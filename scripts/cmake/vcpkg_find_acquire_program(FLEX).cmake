if(CMAKE_HOST_WIN32)
    # This download shall be the same as in vcpkg_find_acquire_program(BISON).cmake
    # Note that this is 2.5.24 rather than 2.5.25 due to a race in %TEMP% in 2.5.25
    # For more information, see: https://github.com/microsoft/vcpkg/issues/29139
    # or: https://github.com/lexxmark/winflexbison/issues/86
    set(program_version 2.5.24)
    set(download_urls "https://github.com/lexxmark/winflexbison/releases/download/v${program_version}/win_flex_bison-${program_version}.zip")
    set(download_filename "win_flex_bison-${program_version}.zip")
    set(download_sha512 dc89fcdaa7071fbbf88b0755b799d69223240c28736924b4c30968c08e7e0b116c7e05ae98a9257be26a1dfb4aa70a628808a6b6018706bf857555c5b4335018)
    set(tool_subdirectory "${program_version}")
    set(program_name win_flex)
    set(paths_to_search "${DOWNLOADS}/tools/win_flex/${program_version}")
    if(NOT EXISTS "${paths_to_search}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${paths_to_search}")
    endif()
else()
    set(program_name flex)
    set(apt_package_name flex)
    set(brew_package_name flex)
endif()
