if(NOT _VCPKG_CLANGCL_TOOLCHAIN)
set(_VCPKG_CLANGCL_TOOLCHAIN 1)

find_program(CMAKE_C_COMPILER "clang-cl.exe")
find_program(CMAKE_CXX_COMPILER "clang-cl.exe")

if(DEFINED XBOX_CONSOLE_TARGET)
    include("${CMAKE_CURRENT_LIST_DIR}/xbox.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/windows.cmake")
endif()

endif()
