# not modern
find_package(LIBFTDI1 NAMES LibFTDI1 REQUIRED)
include("${LIBFTDI_USE_FILE}")

add_executable(cmake-usage ../main.cpp)
target_link_libraries(cmake-usage PRIVATE ${LIBFTDIPP_LIBRARIES})
