cmake_minimum_required(VERSION 3.5)
project(libpqxx VERSION 6.4.3 LANGUAGES CXX)

set(CMAKE_DEBUG_POSTFIX "d")
set(CMAKE_CXX_STANDARD 14)

find_library(LIBPQD NAMES libpqd pqd)
find_library(LIBPQ NAMES libpq pq)
find_path(LIBPQ_FE_H libpq-fe.h)
find_path(POSTGRES_EXT_H postgres_ext.h)

include(CheckIncludeFileCXX)

check_include_file_cxx(poll.h HAVE_POLL)
check_include_file_cxx(sys/select.h HAVE_SYS_SELECT_H)
check_include_file_cxx(sys/time.h HAVE_SYS_TIME_H)
check_include_file_cxx(sys/types.h HAVE_SYS_TYPES_H)
check_include_file_cxx(unistd.h HAVE_UNISTD_H)

include(CheckCXXSourceCompiles)

check_cxx_source_compiles("[[deprecated]] void f();
int main() { return 0; }" PQXX_HAVE_DEPRECATED)
check_cxx_source_compiles("#include <optional>
int main() { return std::optional<int>(0).value(); }" PQXX_HAVE_OPTIONAL)
check_cxx_source_compiles("#include <experimental/optional>
int main() { return std::experimental::optional<int>(0).value(); }" PQXX_HAVE_EXP_OPTIONAL)

configure_file(config-internal-compiler.h.in pqxx/config-internal-compiler.h)
configure_file(config-public-compiler.h.in pqxx/config-public-compiler.h)

file(GLOB SRCS "${PROJECT_SOURCE_DIR}/src/*.cxx")

if(BUILD_SHARED_LIBS)
    set(TARGET libpqxx)
    set(SHARED_DEFINITION -DPQXX_SHARED)
    if(MSVC)
        list(APPEND SRCS "${PROJECT_SOURCE_DIR}/win32/libpqxx.cxx")
    endif()
else()
    set(TARGET libpqxx_static)
    set(SHARED_DEFINITION "")
endif()

IF(UNIX)
    set(TARGET pqxx_static)
ENDIF()

add_library(${TARGET} ${SRCS})
target_compile_definitions(${TARGET} PRIVATE -DPQXX_INTERNAL -DNOMINMAX ${SHARED_DEFINITION})
target_include_directories(${TARGET} PRIVATE include ${LIBPQ_FE_H} ${POSTGRES_EXT_H} ${CMAKE_BINARY_DIR})
target_link_libraries(${TARGET} PRIVATE ws2_32)
if(LIBPQD AND LIBPQ)
    target_link_libraries(${TARGET} PRIVATE debug ${LIBPQD} optimized ${LIBPQ})
elseif(LIBPQD)
    target_link_libraries(${TARGET} PRIVATE ${LIBPQD})
else()
    target_link_libraries(${TARGET} PRIVATE ${LIBPQ})
endif()

install(TARGETS ${TARGET}
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    )
install(DIRECTORY include/ DESTINATION include 
    CONFIGURATIONS Release
    PATTERN "doc" EXCLUDE
    PATTERN "*.am" EXCLUDE
    PATTERN "*.in" EXCLUDE
    PATTERN "*.template" EXCLUDE
    PATTERN "CMakeLists.txt" EXCLUDE
    )
install(DIRECTORY ${CMAKE_BINARY_DIR}/pqxx/ DESTINATION include/pqxx
    CONFIGURATIONS Release
    FILES_MATCHING PATTERN "*.h"
    )
