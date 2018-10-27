project(uwebsockets CXX)

option(INSTALL_HEADERS "Install header files" ON)

find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)
find_path(LIBUV_INCLUDE_DIR uv.h)
find_library(LIBUV_LIBRARY NAMES libuv)

file(GLOB SOURCES src/*.cpp)
add_library(uWS ${SOURCES})
target_include_directories(uWS PUBLIC ${OPENSSL_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS})
target_link_libraries(uWS PUBLIC ${OPENSSL_LIBRARIES} ${ZLIB_LIBRARIES} ${LIBUV_LIBRARY})
target_compile_features(uWS PRIVATE cxx_range_for)

install(TARGETS uWS
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(INSTALL_HEADERS)
    file(GLOB HEADERS src/*.h)
    install(FILES ${HEADERS} DESTINATION include/uWS)
endif()
