cmake_minimum_required(VERSION 3.8)
project(leveldb C CXX)

option(INSTALL_HEADERS "Install header files" ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

IF (MSVC)
add_definitions(
       -DWIN32
       -D_CRT_NONSTDC_NO_DEPRECATE
       -D_SCL_SECURE_NO_WARNINGS
       -D_CRT_SECURE_NO_WARNINGS
       -DNOMINMAX
       -DLEVELDB_PLATFORM_WINDOWS
       -DLEVELDB_ATOMIC_PRESENT
)
else ()
add_definitions(
       -DLEVELDB_PLATFORM_POSIX
       -DLEVELDB_ATOMIC_PRESENT
)
endif()
set(SRCS
    db/builder.cc
    db/c.cc
    db/dbformat.cc
    db/db_impl.cc
    db/db_iter.cc
    db/dumpfile.cc
    db/filename.cc
    db/log_reader.cc
    db/log_writer.cc
    db/memtable.cc
    db/repair.cc
    db/table_cache.cc
    db/version_edit.cc
    db/version_set.cc
    db/write_batch.cc
    helpers/memenv/memenv.cc
    port/port_posix_sse.cc
    table/block.cc
    table/block_builder.cc
    table/filter_block.cc
    table/format.cc
    table/iterator.cc
    table/merger.cc
    table/table.cc
    table/table_builder.cc
    table/two_level_iterator.cc
    util/arena.cc
    util/bloom.cc
    util/cache.cc
    util/coding.cc
    util/comparator.cc
    util/crc32c.cc
    util/env.cc
    util/filter_policy.cc
    util/hash.cc
    util/histogram.cc
    util/logging.cc
    util/options.cc
    util/status.cc
)

if (MSVC)
set(SRCS ${SRCS} port/port_win.cc util/env_win.cc)
else ()
set(SRCS ${SRCS} port/port_posix.cc util/env_posix.cc)
ENDIF()

add_library(leveldb ${SRCS})

target_include_directories(leveldb
    PUBLIC include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(leveldb PUBLIC Iphlpapi.lib Shlwapi.lib)

install(TARGETS leveldb
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(INSTALL_HEADERS)
	file(GLOB HEADERS include/leveldb/*.h)
	install(FILES ${HEADERS} DESTINATION include/leveldb)
	install(FILES helpers/memenv/memenv.h DESTINATION include)
endif()
