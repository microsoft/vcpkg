vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fawdlstty/libfv
    REF v${VERSION}
    SHA512 9ad1c4a6e72d4a4208d4b5347b4be44b4894d777f293666d34ac76b53eb3d15ae79cd46d3315459dd2c3ca1c6d08691e31d37cc0636444278ca35144a7423902
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
