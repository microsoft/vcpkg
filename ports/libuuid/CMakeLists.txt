cmake_minimum_required(VERSION 3.0)
project(libuuid C)

configure_file(config.linux.h config.h COPYONLY)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(uuid STATIC
    clear.c
    compare.c
    copy.c
    gen_uuid.c
    isnull.c
    pack.c
    parse.c
    randutils.c
    unpack.c
    unparse.c
    uuid_time.c
)
target_compile_options(uuid PRIVATE -include "${CMAKE_CURRENT_BINARY_DIR}/config.h")

add_executable(test_uuid test_uuid.c)
target_link_libraries(test_uuid uuid)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    install(FILES uuid.h DESTINATION include/uuid)
endif()

install(
    TARGETS uuid
    EXPORT uuid_targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

include(CMakePackageConfigHelpers)
set(PACKAGE_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libuuid-config.cmake")
set(INSTALL_CONFIG_DIR  "${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-libuuid")

configure_package_config_file(unofficial-libuuid-config.cmake.in
    "${PACKAGE_CONFIG_FILE}"
    INSTALL_DESTINATION "${INSTALL_CONFIG_DIR}"
)

export(EXPORT uuid_targets
    NAMESPACE unofficial::UUID::
    FILE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libuuid-targets.cmake"
)

install(EXPORT uuid_targets
    NAMESPACE unofficial::UUID::
    FILE unofficial-libuuid-targets.cmake
    DESTINATION "${INSTALL_CONFIG_DIR}"
)

install(
    FILES
        "${PACKAGE_CONFIG_FILE}"
    DESTINATION
        "${INSTALL_CONFIG_DIR}"
)
