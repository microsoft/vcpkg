# Use separate compiler PDBs (/Zi) instead of embedded debug info (/Z7) so
# MSVC static libraries do not become excessively large. Upstream CMakeLists.txt
# already sets per-target COMPILE_PDB_NAME and installs each target's PDB.
foreach(language IN ITEMS C CXX)
    if(CMAKE_${language}_COMPILER_ID STREQUAL "MSVC")
        foreach(suffix IN ITEMS "" _DEBUG _RELEASE)
            string(REPLACE "/Z7" "/Zi" CMAKE_${language}_FLAGS${suffix} "${CMAKE_${language}_FLAGS${suffix}}")
        endforeach()
    endif()
endforeach()
if(CMAKE_C_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "ProgramDatabase")
endif()
