cmake_minimum_required(VERSION 3.13)
project(wxchartdir CXX)

set(wxWidgets_EXCLUDE_COMMON_LIBRARIES TRUE)
find_package(wxWidgets REQUIRED COMPONENTS core base)
include(${wxWidgets_USE_FILE})

find_package(chartdir CONFIG REQUIRED)

add_library(wxchartdir STATIC wxdemo/common/wxchartviewer.cpp)

target_include_directories(wxchartdir PUBLIC
	$<INSTALL_INTERFACE:include>
)

target_link_libraries(wxchartdir 
	PRIVATE ${wxWidgets_LIBRARIES}
	PRIVATE chartdir
)

install(TARGETS wxchartdir EXPORT wxchartdir-config 
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(EXPORT wxchartdir-config DESTINATION share/cmake/wxchartdir)

install(FILES wxdemo/common/mondrian.xpm DESTINATION include/wxchartdir)
install(FILES wxdemo/common/wxchartviewer.h DESTINATION include/wxchartdir)
install(FILES wxdemo/common/wxchartviewer_defs.h DESTINATION include/wxchartdir)
install(FILES wxdemo/common/wxchartviewer_version.h DESTINATION include/wxchartdir)
install(FILES wxdemo/common/wxchartviewer_version.rc DESTINATION include/wxchartdir)


add_executable(wxchartdir_helloworld 
	wxdemo/helloworld/helloworld.cpp 
	wxdemo/helloworld/helloworldapp.cpp
)

target_include_directories(wxchartdir_helloworld PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/wxdemo/common>
)

target_link_libraries(wxchartdir_helloworld 
	PRIVATE ${wxWidgets_LIBRARIES}
	PRIVATE chartdir
	PRIVATE wxchartdir
)

install(TARGETS wxchartdir_helloworld DESTINATION tools/wxchartdir)
