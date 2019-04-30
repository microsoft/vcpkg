cmake_minimum_required(VERSION 3.12)

project(libpff C)

find_package(zlib REQUIRED)

if(MSVC)
    add_compile_definitions(_CRT_SECURE_NO_DEPRECATE)
    add_compile_definitions(_CRT_NONSTDC_NO_DEPRECATE)
endif()

add_compile_definitions(HAVE_LOCAL_LIBCERROR)
add_compile_definitions(HAVE_LOCAL_LIBCTHREADS)
add_compile_definitions(HAVE_LOCAL_LIBCDATA)
add_compile_definitions(HAVE_LOCAL_LIBCLOCALE)
add_compile_definitions(HAVE_LOCAL_LIBCNOTIFY)
add_compile_definitions(HAVE_LOCAL_LIBCSPLIT)
add_compile_definitions(HAVE_LOCAL_LIBCFILE)
add_compile_definitions(HAVE_LOCAL_LIBCPATH)
add_compile_definitions(HAVE_LOCAL_LIBUNA)
add_compile_definitions(HAVE_LOCAL_LIBBFIO)
add_compile_definitions(HAVE_LOCAL_LIBFCACHE)
add_compile_definitions(HAVE_LOCAL_LIBFDATA)
add_compile_definitions(HAVE_LOCAL_LIBFDATETIME)
add_compile_definitions(HAVE_LOCAL_LIBFGUID)
add_compile_definitions(HAVE_LOCAL_LIBFWNT)
add_compile_definitions(HAVE_LOCAL_LIBFMAPI)
add_compile_definitions(HAVE_LOCAL_LIBFVALUE)
add_compile_definitions(ZLIB_DLL)

add_compile_definitions(LIBPFF_DLL_EXPORT)

if(MSVC)
    set(LIB_RC libpff/libpff.rc)
endif()

# Source files
file(GLOB LIB_SRC lib*/*.c)

# Headers
file(GLOB LIB_INST_HEADERS include/libpff/*.h)

add_library(${PROJECT_NAME} ${LIB_SRC} ${LIB_RC})

target_include_directories(${PROJECT_NAME} PRIVATE ./include ./common)
target_include_directories(${PROJECT_NAME} PRIVATE ./libbfio ./libcdata ./libcerror ./libcfile ./libclocale ./libcnotify)
target_include_directories(${PROJECT_NAME} PRIVATE ./libcpath ./libcsplit ./libcthreads ./libfcache ./libfdata ./libfdatetime)
target_include_directories(${PROJECT_NAME} PRIVATE ./libfguid ./libfmapi ./libfvalue ./libfwnt ./libuna)

target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES ${LIB_INST_HEADERS} DESTINATION include/libpff)
install(FILES include/libpff.h DESTINATION include)
