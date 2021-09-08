project(stb)
# create a library for stb
add_library(stb "stb_vorbis.h" "stb_vorbis.c")
target_compile_definitions(stb PRIVATE "STB_VORBIS_EXPORTS")
# install library
install(TARGETS stb
    EXPORT stb_targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)
install(EXPORT stb_targets
    FILE stb-config.cmake
    NAMESPACE stb::
    DESTINATION share/stb
)
export(TARGETS stb
    NAMESPACE stb::
    FILE "${CMAKE_CURRENT_BINARY_DIR}/stb-config.cmake"
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/stb-config.cmake"
    DESTINATION share/stb
)