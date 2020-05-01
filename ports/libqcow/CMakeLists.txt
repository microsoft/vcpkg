cmake_minimum_required(VERSION 3.12)

project(libqcow C)

find_package(OpenSSL)
find_package(ZLIB REQUIRED)

if(MSVC)
    add_compile_definitions(_CRT_SECURE_NO_DEPRECATE)
    add_compile_definitions(_CRT_NONSTDC_NO_DEPRECATE)
endif()

add_compile_definitions(HAVE_LOCAL_LIBCAES)
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
add_compile_definitions(ZLIB_DLL)

if(UNIX)
    configure_file(common/config.h.in common/config.h)
    add_compile_definitions(HAVE_CONFIG_H)
    add_compile_definitions(LOCALEDIR="/usr/share/locale")
endif()

if(MSVC)
    add_compile_definitions(LIBQCOW_DLL_EXPORT)
    set(LIB_RC libqcow/libqcow.rc)
endif()


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Add CMake find_package() integration
set(PROJECT_TARGET_NAME "${PROJECT_NAME}")
set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(PROJECT_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/generated/${PROJECT_TARGET_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_TARGET_NAME}Targets")
set(NAMESPACE "libqcow::")

# Source files
file(GLOB LIB_SRC lib*/*.c)

# Headers
file(GLOB LIB_INST_HEADERS include/libqcow/*.h)

add_library(${PROJECT_NAME} ${LIB_SRC} ${LIB_RC})

target_include_directories(${PROJECT_NAME} PRIVATE ./include ./common)
target_include_directories(${PROJECT_NAME} PRIVATE ./libbfio ./libcaes ./libcdata ./libcerror ./libcfile ./libclocale)
target_include_directories(${PROJECT_NAME} PRIVATE ./libcnotify ./libcpath ./libcsplit ./libcthreads)
target_include_directories(${PROJECT_NAME} PRIVATE ./libfcache ./libfdata ./libuna)

target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB OpenSSL::Crypto)

install(TARGETS ${PROJECT_NAME}
        EXPORT ${TARGETS_EXPORT_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        INCLUDES DESTINATION include)

install(FILES ${LIB_INST_HEADERS} DESTINATION include/libqcow)
install(FILES include/libqcow.h DESTINATION include)


# Generate and install libqcowConfig.cmake
configure_package_config_file("Config.cmake.in" "${PROJECT_CONFIG}" INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}")
install(FILES "${PROJECT_CONFIG}" DESTINATION "${CONFIG_INSTALL_DIR}")

# Generate and install libqcowTargets*.cmake
install(EXPORT ${TARGETS_EXPORT_NAME}
        NAMESPACE ${NAMESPACE}
        DESTINATION "${CONFIG_INSTALL_DIR}")
