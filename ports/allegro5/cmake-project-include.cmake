if(MSVC AND CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
    add_compile_options(/Gy)
endif()
