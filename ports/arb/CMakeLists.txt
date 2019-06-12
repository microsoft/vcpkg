cmake_minimum_required(VERSION 2.8.12)

project(arb C)

set (DEPS mpir mpfr pthreads flint2 gettimeofday)
set (mpir_lib gmp mpir)
set (mpfr_lib mpfr)
set (pthreads_lib pthreads pthread pthreadVC2 pthreadVC3)
set (flint2_lib ${LIBRARY_TYPE}_flint flint)
set (gettimeofday_lib gettimeofday)

set (mpir_header gmp.h)
set (mpfr_header mpfr.h)
set (pthreads_header pthread.h)
set (flint2_header flint/flint.h)
set (gettimeofday_header gettimeofday.h)

foreach (LIB ${DEPS})
    string (TOUPPER ${LIB} LIB_UPPER)
    find_library(${LIB_UPPER}_LIBRARY NAMES ${${LIB}_lib})
    if (NOT ${LIB_UPPER}_LIBRARY)
        message(FATAL_ERROR "${LIB} library not found.")
    endif()
    add_library(${LIB} UNKNOWN IMPORTED)
    set_property(TARGET ${LIB} PROPERTY IMPORTED_LOCATION ${${LIB_UPPER}_LIBRARY})
    message("${LIB} found in ${${LIB_UPPER}_LIBRARY}")
endforeach ()

foreach (LIB ${DEPS})
    string(TOUPPER ${LIB} HEADER_PKG)
    set (HEADER ${${LIB}_header})
    find_path(${HEADER_PKG}_INCLUDE_DIR NAMES ${HEADER})
    if (NOT ${HEADER_PKG}_INCLUDE_DIR)
        message(FATAL_ERROR "${HEADER} header not found.")
    endif()
    message("${HEADER} found in ${${HEADER_PKG}_INCLUDE_DIR}")
    set (DEP_INCLUDE_DIRS ${DEP_INCLUDE_DIRS} ${${HEADER_PKG}_INCLUDE_DIR})
endforeach ()

file(GLOB TEMP "*.h")

foreach (TEMP_H ${TEMP})
    get_filename_component(FOLDER ${TEMP_H} NAME_WE)
    set(FOLDERS ${FOLDERS} ${FOLDER})
endforeach()

foreach (FOLDER ${FOLDERS})
    file(GLOB TEMP "${FOLDER}/*.c")
    set(SRC ${SRC} ${TEMP})
endforeach ()

include_directories(BEFORE ${arb_SOURCE_DIR})
include_directories(BEFORE ${DEP_INCLUDE_DIRS})

add_library(arb ${SRC})

target_compile_definitions(arb PRIVATE HAVE_TLS=1 FLINT_REENTRANT=0)
target_compile_definitions(arb PRIVATE PTW32_STATIC_LIB)
MESSAGE( STATUS "Building static libraries" )
target_compile_definitions(arb PRIVATE "ARB_BUILD_DLL")

target_link_libraries(arb ${DEPS})

install(TARGETS arb
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
        )

foreach (FOLDER ${FOLDERS})
    set(HEADERS ${HEADERS} ${FOLDER}.h)
endforeach ()

install(FILES ${HEADERS} DESTINATION include)

if (BUILD_TESTS)
    enable_testing()
    foreach (FOLDER ${FOLDERS})
        file(GLOB TEMP "${FOLDER}/test/*.c")
        foreach (TEST_SOURCE ${TEMP})
            get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)
            add_executable(${FOLDER}-${TEST_NAME} ${TEST_SOURCE})
            target_link_libraries(${FOLDER}-${TEST_NAME} arb)
            add_test(${FOLDER}-${TEST_NAME} ${FOLDER}-${TEST_NAME})
        endforeach ()
    endforeach ()
endif ()
