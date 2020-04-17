cmake_minimum_required(VERSION 2.8.10)
project(blosc_h5)

find_package(hdf5 CONFIG REQUIRED)
find_package(blosc CONFIG REQUIRED)

# H5Zblosc (plugin)
add_library(H5Zblosc SHARED blosc_filter.c blosc_plugin.c)
target_link_libraries(H5Zblosc PRIVATE blosc $<IF:${blosc_h5_SHARED},hdf5::hdf5-shared,hdf5::hdf5-static>)
install(TARGETS H5Zblosc RUNTIME DESTINATION plugin ARCHIVE DESTINATION plugin LIBRARY DESTINATION plugin)

# blosc_filter
if(blosc_h5_SHARED)
	add_library(blosc_filter SHARED blosc_filter.c)
	target_compile_definitions(blosc_filter PRIVATE blosc_filter_API_EXPORTS)
	target_link_libraries(blosc_filter PRIVATE blosc hdf5::hdf5-shared)
else()
	add_library(blosc_filter STATIC blosc_filter.c)
	target_compile_definitions(blosc_filter PUBLIC blosc_h5_STATIC)
	target_link_libraries(blosc_filter PUBLIC blosc hdf5::hdf5-static)
endif()

target_include_directories(blosc_filter PUBLIC $<INSTALL_INTERFACE:include>)
install(TARGETS blosc_filter EXPORT hdf5-blosc-config RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
install(EXPORT hdf5-blosc-config DESTINATION share/cmake/hdf5-blosc)
install(FILES blosc_filter.h DESTINATION include)
