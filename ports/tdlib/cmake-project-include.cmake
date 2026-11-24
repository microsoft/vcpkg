# Embedded debug information can make the MSVC static archives exceed 4 GiB.
foreach(language IN ITEMS C CXX)
    foreach(suffix IN ITEMS "" _DEBUG _RELEASE)
        string(REPLACE "/Z7" "/Zi" CMAKE_${language}_FLAGS${suffix} "${CMAKE_${language}_FLAGS${suffix}}")
    endforeach()
endforeach()
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "ProgramDatabase")

function(tdlib_set_static_pdb_names directory)
    get_property(targets DIRECTORY "${directory}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(target IN LISTS targets)
        get_target_property(type "${target}" TYPE)
        if(type STREQUAL "STATIC_LIBRARY")
            set_target_properties("${target}" PROPERTIES
                COMPILE_PDB_NAME "${target}"
                COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/compiler-pdb/$<CONFIG>"
            )
        endif()
    endforeach()
    get_property(subdirectories DIRECTORY "${directory}" PROPERTY SUBDIRECTORIES)
    foreach(subdirectory IN LISTS subdirectories)
        tdlib_set_static_pdb_names("${subdirectory}")
    endforeach()
endfunction()
cmake_language(DEFER CALL tdlib_set_static_pdb_names "${CMAKE_SOURCE_DIR}")
