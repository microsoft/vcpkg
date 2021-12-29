cmake_minimum_required(VERSION 3.0)
project(libideviceactivation C)

# find dependencies
find_library(libplist NAMES plist plist-2.0 libplist libplist-2.0 REQUIRED)
find_path(libimobiledevice_INCLUDES endianness.h)
find_library(libimobiledevice NAMES imobiledevice imobiledevice-1.0 libimobiledevice libimobiledevice-1.0 REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(CURL REQUIRED)

# ready to create library
file(GLOB_RECURSE IDVCACTV_TOOLS_SRC common/*.c)

file(GLOB_RECURSE IDVCACTV_PUBLIC_HDR include/*.h)
file(GLOB_RECURSE IDVCACTV_SRC src/*.c)

add_library(libideviceactivation ${IDVCACTV_TOOLS_SRC} ${IDVCACTV_SRC} ${IDVCACTV_PUBLIC_HDR})
target_include_directories(libideviceactivation PRIVATE ${libimobiledevice_INCLUDES} ${LIBXML2_INCLUDE_DIR} ${CURL_INCLUDE_DIRS} include)
target_compile_definitions(libideviceactivation PRIVATE -DHAVE_OPENSSL)
target_link_libraries(libideviceactivation PRIVATE ${libplist} ${libimobiledevice} ${CURL_LIBRARIES} ${LIBXML2_LIBRARIES})

# install
install(
    TARGETS libideviceactivation
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libideviceactivation-1.0.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc
    @ONLY
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libideviceactivation-1.0.pc
    DESTINATION lib/pkgconfig
)

install(FILES ${IDVCACTV_PUBLIC_HDR} DESTINATION include)