cmake_minimum_required(VERSION 3.19)
project(libaes-siv LANGUAGES C)
set(PROJECT_VERSION "${VERSION}")

set(Header_Files "aes_siv.h")
set(Source_Files "aes_siv.c")

add_library("${PROJECT_NAME}" "${Header_Files}" "${Source_Files}")

include(GNUInstallDirs)
target_include_directories(
  "${PROJECT_NAME}"
  PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
  "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_features("${PROJECT_NAME}" PRIVATE c_std_99)
set(config_file "${CMAKE_BINARY_DIR}/include/aes_siv_config.h")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/config.h.in" "${config_file}")
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_C_FLAGS_DEBUG "-Wall -Wextra -Wstrict-prototypes -Wconversion -Og -ggdb3 -ftree-vectorize")
    set(CMAKE_C_FLAGS_RELEASE "-Wall -Wextra -Wstrict-prototypes -Wconversion -O3 -fomit-frame-pointer -funroll-loops -ftree-vectorize -DNDEBUG")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Wall -Wextra -Wstrict-prototypes -Wconversion  -ggdb3 -O3 -funroll-loops -ftree-vectorize -DNDEBUG")
    set(CMAKE_C_FLAGS_MINSIZEREL "-Wall -Wextra -Wstrict-prototypes -Wconversion -Os -fomit-frame-pointer -ftree-vectorize -DNDEBUG")
endif(CMAKE_C_COMPILER_ID STREQUAL "GNU")

if(CMAKE_C_COMPILER_ID STREQUAL Clang OR CMAKE_C_COMPILER_ID STREQUAL AppleClang)
    set(CMAKE_C_FLAGS_DEBUG "-Wall -Wextra -Wstrict-prototypes -Wconversion -O0 -ggdb3 -ftree-vectorize")
    set(CMAKE_C_FLAGS_RELEASE "-Wall -Wextra -Wstrict-prototypes -Wconversion -O3 -fomit-frame-pointer -funroll-loops -ftree-vectorize -DNDEBUG")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Wall -Wextra -Wstrict-prototypes -Wconversion -ggdb3 -O3 -funroll-loops -ftree-vectorize -DNDEBUG")
    set(CMAKE_C_FLAGS_MINSIZEREL "-Wall -Wextra -Wstrict-prototypes -Wconversion -Os -fomit-frame-pointer -ftree-vectorize -DNDEBUG")
endif(CMAKE_C_COMPILER_ID STREQUAL Clang OR CMAKE_C_COMPILER_ID STREQUAL AppleClang)

find_package(OpenSSL REQUIRED COMPONENTS Crypto)
target_link_libraries("${PROJECT_NAME}" PRIVATE OpenSSL::Crypto)

install(
  TARGETS                   "${PROJECT_NAME}"
  EXPORT                    "unofficial-${PROJECT_NAME}Config"
  RUNTIME       DESTINATION "${CMAKE_INSTALL_BINDIR}"
  ARCHIVE       DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY       DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

include(CMakePackageConfigHelpers)
set(VERSION_FILE_PATH "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}ConfigVersion.cmake")
write_basic_package_version_file(
        "${VERSION_FILE_PATH}"
        VERSION       "${PROJECT_VERSION}"
        COMPATIBILITY SameMajorVersion
)
install(FILES "${VERSION_FILE_PATH}" DESTINATION "share/unofficial-${PROJECT_NAME}")
install(FILES ${Header_Files} "${config_file}"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(
  EXPORT      "unofficial-${PROJECT_NAME}Config"
  FILE        "unofficial-${PROJECT_NAME}Config.cmake"
  NAMESPACE   "unofficial::${PROJECT_NAME}::"
  DESTINATION "share/unofficial-${PROJECT_NAME}")

export(PACKAGE "${PROJECT_NAME}")
