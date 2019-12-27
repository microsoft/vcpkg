cmake_minimum_required(VERSION 3.5)
project(detours CXX)

add_library(detours INTERFACE)

target_link_libraries(detours INTERFACE debug \${_IMPORT_PREFIX}/debug/lib/detours.lib optimized \${_IMPORT_PREFIX}/lib/detours.lib)
target_include_directories(detours INTERFACE $<INSTALL_INTERFACE:include>)

install(TARGETS detours
    EXPORT detours
)
install(EXPORT detours FILE unofficial-detours-targets.cmake NAMESPACE unofficial::detours:: DESTINATION share/unofficial-detours)
