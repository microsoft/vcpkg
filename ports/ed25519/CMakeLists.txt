cmake_minimum_required(VERSION 3.19)
project(ed25519 LANGUAGES C)
set(PROJECT_VERSION "${VERSION}")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ed25519.h" "#elif defined(ED25519_DLL)" "#elif 1")
endif()
set(Header_Files "src/ed25519.h"
        "src/fe.h"
        "src/fixedint.h"
        "src/ge.h"
        "src/precomp_data.h"
        "src/sc.h"
        "src/sha512.h")
set(Source_Files "src/add_scalar.c"
        "src/fe.c"
        "src/ge.c"
        "src/key_exchange.c"
        "src/keypair.c"
        "src/sc.c"
        "src/seed.c"
        "src/sha512.c"
        "src/sign.c"
        "src/verify.c")

add_library("${PROJECT_NAME}" "${Header_Files}" "${Source_Files}")

include(GNUInstallDirs)
target_include_directories(
  "${PROJECT_NAME}"
  PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_features("${PROJECT_NAME}" PRIVATE c_std_90)
set_target_properties("${PROJECT_NAME}" PROPERTIES C_VISIBILITY_PRESET hidden
                      PUBLIC_HEADER "src/ed25519.h")

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
install(FILES "src/ed25519.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(
  EXPORT      "unofficial-${PROJECT_NAME}Config"
  FILE        "unofficial-${PROJECT_NAME}Config.cmake"
  NAMESPACE   "unofficial::${PROJECT_NAME}::"
  DESTINATION "share/unofficial-${PROJECT_NAME}")

export(PACKAGE "${PROJECT_NAME}")
