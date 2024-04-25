vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fawdlstty/libfv
    REF v0.0.8
    SHA512 66071db541269de9793c643fba6154d1743b047ac32486067207c88d61b706e81266ce365a5c96c203a1cea0ec4e406927d8a8df1e047bb8b9218cf741dae4f1
    HEAD_REF master
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/fawdlstty-libfv/fawdlstty-libfv-config.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(OpenSSL)
find_dependency(ZLIB)
if(NOT TARGET fawdlstty-libfv::libfv)
  add_library(fawdlstty-libfv::libfv INTERFACE IMPORTED)
  target_include_directories(fawdlstty-libfv::libfv INTERFACE \"\${CMAKE_CURRENT_LIST_DIR}/../../include\")
  target_link_libraries(fawdlstty-libfv::libfv INTERFACE ZLIB::ZLIB OpenSSL::SSL)
endif()
")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
