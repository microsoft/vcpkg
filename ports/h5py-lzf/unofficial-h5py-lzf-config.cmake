include(CMakeFindDependencyMacro)
find_dependency(hdf5 CONFIG)
find_dependency(unofficial-liblzf CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-h5py-lzf-targets.cmake")
