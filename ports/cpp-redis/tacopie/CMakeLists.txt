find_library(TACOPIE tacopie)
find_path(TACOPIE_H tacopie/tacopie)

message(STATUS "TACOPIE_H: ${TACOPIE_H}")

add_library(tacopie INTERFACE)
target_link_libraries(tacopie INTERFACE "${TACOPIE}")
target_include_directories(tacopie INTERFACE "${TACOPIE_H}")