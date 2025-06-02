
install(
    EXPORT unofficial-aliyun-oss-cpp-sdk-targets
    NAMESPACE unofficial::aliyun-oss-cpp-sdk::
    DESTINATION share/unofficial-aliyun-oss-cpp-sdk
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-aliyun-oss-cpp-sdk-config.cmake.in" [[
@PACKAGE_INIT@
include(CMakeFindDependencyMacro)
find_dependency(CURL REQUIRED)
find_dependency(OpenSSL REQUIRED)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-aliyun-oss-cpp-sdk-targets.cmake")
]]
)

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-aliyun-oss-cpp-sdk-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-aliyun-oss-cpp-sdk-config.cmake"
    INSTALL_DESTINATION "share/unofficial-aliyun-oss-cpp-sdk"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-aliyun-oss-cpp-sdk-config.cmake"
    DESTINATION "share/unofficial-aliyun-oss-cpp-sdk"
)
