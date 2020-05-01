
set(MSVC_VERSION 1900) # Doesn't really matter for gfortran. Just to get around the Version check in Windows-MSVC and get the variables set
include(Platform/Windows) # Mainly sets library suffixes and prefixes for windows
include(Platform/Windows-MSVC)
set(CMAKE_CREATE_WIN32_EXE  "-mwindows") # Need to use MinGW tools to build Fortran executables!
set(CMAKE_CREATE_CONSOLE_EXE "")

#overrides 
#__windows_compiler_gnu_abi(Fortran)



# if(NOT CMAKE_Fortran_COMPILE_OPTIONS_PIC)
  # set(CMAKE_Fortran_COMPILE_OPTIONS_PIC ${CMAKE_C_COMPILE_OPTIONS_PIC})
# endif()

# if(NOT CMAKE_Fortran_COMPILE_OPTIONS_PIE)
  # set(CMAKE_Fortran_COMPILE_OPTIONS_PIE ${CMAKE_C_COMPILE_OPTIONS_PIE})
# endif()
# if(NOT CMAKE_Fortran_LINK_OPTIONS_PIE)
  # set(CMAKE_Fortran_LINK_OPTIONS_PIE ${CMAKE_C_LINK_OPTIONS_PIE})
# endif()
# if(NOT CMAKE_Fortran_LINK_OPTIONS_NO_PIE)
  # set(CMAKE_Fortran_LINK_OPTIONS_NO_PIE ${CMAKE_C_LINK_OPTIONS_NO_PIE})
# endif()

# if(NOT CMAKE_Fortran_COMPILE_OPTIONS_DLL)
  # set(CMAKE_Fortran_COMPILE_OPTIONS_DLL ${CMAKE_C_COMPILE_OPTIONS_DLL})
# endif()

# Create a set of shared library variable specific to Fortran
# For 90% of the systems, these are the same flags as the C versions
# so if these are not set just copy the flags from the c version
# if(NOT DEFINED CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS)
  # set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_Fortran_FLAGS)
  # set(CMAKE_SHARED_LIBRARY_Fortran_FLAGS ${CMAKE_SHARED_LIBRARY_C_FLAGS})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS)
  # set(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS ${CMAKE_SHARED_LIBRARY_LINK_C_FLAGS})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_RUNTIME_Fortran_FLAG)
  # set(CMAKE_SHARED_LIBRARY_RUNTIME_Fortran_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_RUNTIME_Fortran_FLAG_SEP)
  # set(CMAKE_SHARED_LIBRARY_RUNTIME_Fortran_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_RPATH_LINK_Fortran_FLAG)
  # set(CMAKE_SHARED_LIBRARY_RPATH_LINK_Fortran_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_C_FLAG})
# endif()

# if(NOT DEFINED CMAKE_EXE_EXPORTS_Fortran_FLAG)
  # set(CMAKE_EXE_EXPORTS_Fortran_FLAG ${CMAKE_EXE_EXPORTS_C_FLAG})
# endif()

# if(NOT DEFINED CMAKE_SHARED_LIBRARY_SONAME_Fortran_FLAG)
  # set(CMAKE_SHARED_LIBRARY_SONAME_Fortran_FLAG ${CMAKE_SHARED_LIBRARY_SONAME_C_FLAG})
# endif()

# for most systems a module is the same as a shared library
# so unless the variable CMAKE_MODULE_EXISTS is set just
# copy the values from the LIBRARY variables

include(CMakeCommonLanguageInclude)
__windows_compiler_msvc(Fortran) # Sets CMAKE_Fortran_CREATE_SHARED_LIBRARY and CMAKE_Fortran_CREATE_STATIC_LIBRARY
set(CMAKE_C_STANDARD_LIBRARIES_INIT "-lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32")
# now define the following rule variables
# CMAKE_Fortran_CREATE_SHARED_LIBRARY
# CMAKE_Fortran_CREATE_SHARED_MODULE
# CMAKE_Fortran_COMPILE_OBJECT
# CMAKE_Fortran_LINK_EXECUTABLE
message(STATUS "CMAKE_Fortran_LINK_EXECUTABLE:${CMAKE_Fortran_LINK_EXECUTABLE}")
#Overrides from MS rules
set(CMAKE_Fortran_COMPILE_OBJECT
    "<CMAKE_Fortran_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -mabi=ms -c <SOURCE> -o <OBJECT>")
set(CMAKE_Fortran_LINK_EXECUTABLE
    "<CMAKE_Fortran_COMPILER> <FLAGS> <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> -mabi=ms <OBJECTS>  -o <TARGET> -Wl,--out-implib,<TARGET_IMPLIB> ${CMAKE_GNULD_IMAGE_VERSION} <LINK_LIBRARIES>")

message(STATUS "CMAKE_Fortran_LINK_EXECUTABLE:${CMAKE_Fortran_LINK_EXECUTABLE}")

if(NOT CMAKE_Fortran_CREATE_SHARED_LIBRARY)
  #set(CMAKE_Fortran_CREATE_SHARED_LIBRARY
  #    "<CMAKE_Fortran_COMPILER> <CMAKE_SHARED_LIBRARY_Fortran_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
  set(CMAKE_Fortran_CREATE_SHARED_LIBRARY
    "${_CMAKE_VS_LINK_DLL}<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <OBJECTS> ${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /dll /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <LINK_FLAGS> <LINK_LIBRARIES> ${CMAKE_END_TEMP_FILE}")

endif()

# create a Fortran shared module just copy the shared library rule
if(NOT CMAKE_Fortran_CREATE_SHARED_MODULE)
  set(CMAKE_Fortran_CREATE_SHARED_MODULE ${CMAKE_Fortran_CREATE_SHARED_LIBRARY})
endif()

# Create a static archive incrementally for large object file counts.
# If CMAKE_Fortran_CREATE_STATIC_LIBRARY is set it will override these.
#if(NOT DEFINED CMAKE_Fortran_ARCHIVE_CREATE)
  #set(CMAKE_Fortran_ARCHIVE_CREATE "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
  #set(CMAKE_Fortran_ARCHIVE_CREATE "<CMAKE_LINKER> /lib <LINK_FLAGS> /out:<TARGET> <OBJECTS> ")
#endif()
#if(NOT DEFINED CMAKE_Fortran_ARCHIVE_APPEND)
  #set(CMAKE_Fortran_ARCHIVE_APPEND "<CMAKE_AR> q  <TARGET> <LINK_FLAGS> <OBJECTS>")
#endif()
#if(NOT DEFINED CMAKE_Fortran_ARCHIVE_FINISH)
  #set(CMAKE_Fortran_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET>")
  #set(CMAKE_Fortran_ARCHIVE_FINISH "")
#endif()

# link a fortran program
if(NOT CMAKE_Fortran_LINK_EXECUTABLE)
  #set(CMAKE_Fortran_LINK_EXECUTABLE
  #  "<CMAKE_Fortran_COMPILER> <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
endif()

if(CMAKE_Fortran_STANDARD_LIBRARIES_INIT)
  set(CMAKE_Fortran_STANDARD_LIBRARIES "${CMAKE_Fortran_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by default with all Fortran applications.")
  mark_as_advanced(CMAKE_Fortran_STANDARD_LIBRARIES)
endif()
