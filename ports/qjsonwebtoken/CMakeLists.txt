cmake_minimum_required(VERSION 3.12.0)

set(PROJECT_VERSION "0.1.0")
project(qjsonwebtoken VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5Core REQUIRED)

set(HEADERS "src/QJsonWebToken" "src/qjsonwebtoken.h")
set(SOURCES "src/qjsonwebtoken.cpp")

add_library(unofficial-qjsonwebtoken ${SOURCES} )
set_target_properties(unofficial-qjsonwebtoken PROPERTIES OUTPUT_NAME qjsonwebtoken)
target_link_libraries(unofficial-qjsonwebtoken Qt5::Core)

include(GenerateExportHeader)
generate_export_header(unofficial-qjsonwebtoken BASE_NAME qjsonwebtoken)

target_include_directories(unofficial-qjsonwebtoken 
    PUBLIC
        $<INSTALL_INTERFACE:include>
)
install(TARGETS unofficial-qjsonwebtoken
    EXPORT qjsonwebtoken-export
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(EXPORT qjsonwebtoken-export
FILE
  qjsonwebtokenTargets.cmake
NAMESPACE
  unofficial-qjsonwebtoken::
DESTINATION
  share/qjsonwebtoken
)
install(FILES ${HEADERS}
	${CMAKE_CURRENT_BINARY_DIR}/qjsonwebtoken_export.h DESTINATION include)
