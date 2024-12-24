cmake_minimum_required(VERSION 3.11)
cmake_policy(VERSION 3.11)

project(autodock-vina)

set(GIT_VERSION v1.2.5)
set(CMAKE_CXX_STANDARD 11)

find_package(Boost REQUIRED COMPONENTS
    filesystem
    log
    program_options
    random
    serialization
    thread
    timer
)

file(GLOB SRC_AUTODOCK_VINA_LIBS
     "src/lib/*.cpp"
)

file(GLOB SRC_AUTODOCK_VINA_SPLIT
     "src/split/*.cpp"
)

file(GLOB HEADERS
     "src/lib/*.h"
)

add_library(vina ${SRC_AUTODOCK_VINA_LIBS})
add_library(vina_split ${SRC_AUTODOCK_VINA_SPLIT})

target_include_directories(vina
     PUBLIC
          $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/lib/>
          $<INSTALL_INTERFACE:include>
     PRIVATE
          $<BUILD_INTERFACE:${Boost_INCLUDE_DIRS}>
)

target_include_directories(vina_split
     PUBLIC
          $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/lib/>
          $<INSTALL_INTERFACE:include>
     PRIVATE
          $<BUILD_INTERFACE:${Boost_INCLUDE_DIRS}>
)

target_compile_definitions(vina
     PUBLIC
          -DVERSION=\"${GIT_VERSION}\"
)

target_compile_definitions(vina_split
     PUBLIC
          -DVERSION=\"${GIT_VERSION}\"
)

target_link_libraries(vina
     PRIVATE
        Boost::boost
        Boost::filesystem
        Boost::log
        Boost::program_options
        Boost::random
        Boost::serialization
        Boost::thread
        Boost::timer
)

target_link_libraries(vina_split
     PRIVATE
        Boost::boost
        Boost::filesystem
        Boost::log
        Boost::program_options
        Boost::random
        Boost::serialization
        Boost::thread
        Boost::timer
)

install(TARGETS vina EXPORT autodock-vina-config
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
)

install(TARGETS vina_split EXPORT autodock-vina-config
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include/autodock-vina)
install(EXPORT autodock-vina-config NAMESPACE autodock-vina::autodock-vina:: DESTINATION share/autodock-vina)
