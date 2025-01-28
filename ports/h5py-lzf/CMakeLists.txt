cmake_minimum_required(VERSION 3.13)
project(h5py-lzf LANGUAGES C)

find_package(hdf5 CONFIG REQUIRED)
find_package(unofficial-liblzf CONFIG REQUIRED)

add_library(h5py-lzf STATIC lzf_filter.c)
target_include_directories(h5py-lzf PUBLIC $<INSTALL_INTERFACE:include>)
target_link_libraries(h5py-lzf PRIVATE
    unofficial::liblzf::liblzf
    $<IF:$<TARGET_EXISTS:hdf5::hdf5-shared>,hdf5::hdf5-shared,hdf5::hdf5-static>
)

install(FILES lzf_filter.h DESTINATION include)
install(TARGETS h5py-lzf
    EXPORT unofficial-h5py-lzf-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(EXPORT unofficial-h5py-lzf-targets
    NAMESPACE unofficial::h5py-lzf::
    DESTINATION share/unofficial-h5py-lzf
)
