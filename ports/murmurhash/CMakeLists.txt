cmake_minimum_required(VERSION 3.14)

set(VERSION "1.0.0")
project(murmurhash LANGUAGES CXX VERSION ${VERSION})

set(CMAKE_CXX_STANDARD 17)

add_library(murmurhash
            src/MurmurHash2.cpp
            src/MurmurHash3.cpp
            )

set(MURMUR_HEADERS
    src/MurmurHash2.h
    src/MurmurHash3.h
    )
set_target_properties(murmurhash PROPERTIES
                      PUBLIC_HEADER "${MURMUR_HEADERS}"
                      )

#Configuration
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
        "${version_config}" COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
        "${CMAKE_SOURCE_DIR}/Config.cmake.in"
        "${project_config}"
        INSTALL_DESTINATION "${config_install_dir}"
)
#Installation
install(TARGETS murmurhash
        EXPORT "${TARGETS_EXPORT_NAME}"
        LIBRARY DESTINATION "lib"
        ARCHIVE DESTINATION "lib"
        PUBLIC_HEADER DESTINATION "include")

install(FILES "${project_config}" "${version_config}"
        DESTINATION "${config_install_dir}"
        )
install(EXPORT "${TARGETS_EXPORT_NAME}"
        NAMESPACE "${namespace}"
        DESTINATION "${config_install_dir}"
        )