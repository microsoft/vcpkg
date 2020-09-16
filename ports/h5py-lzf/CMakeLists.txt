cmake_minimum_required(VERSION 3.13)
project(h5py-lzf)

find_package(hdf5 CONFIG REQUIRED)

add_library(h5py-lzf STATIC lzf_filter.c lzf/lzf_c.c lzf/lzf_d.c)
target_include_directories(h5py-lzf PUBLIC $<INSTALL_INTERFACE:include>)
target_link_libraries(h5py-lzf PRIVATE libzstd $<IF:${link_hdf5_SHARED},hdf5::hdf5-shared,hdf5::hdf5-static>)
install(TARGETS h5py-lzf EXPORT h5py-lzf-config ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
install(EXPORT h5py-lzf-config DESTINATION share/cmake/h5py-lzf)
install(FILES lzf_filter.h lzf/lzf.h DESTINATION include)
