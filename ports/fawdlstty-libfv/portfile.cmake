vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fawdlstty/libfv
    REF v0.0.6
    SHA512 0fdc947cc7035f4218259810ba4a2c951cd45a510daa9cf98caccfbb184808ea76af916db55cac662127a981e8b9c3db76149b6ec1748778728cff98d3f396a2
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
