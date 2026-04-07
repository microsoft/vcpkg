include(CMakeFindDependencyMacro)
find_dependency(asio CONFIG)
find_dependency(msgpack-cxx CONFIG)

get_filename_component(vcpkg_rest_rpc_prefix_path "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(vcpkg_rest_rpc_prefix_path "${vcpkg_rest_rpc_prefix_path}" PATH)

if(NOT TARGET unofficial::rest-rpc::rest-rpc)
    add_library(unofficial::rest-rpc::rest-rpc INTERFACE IMPORTED)
    target_include_directories(unofficial::rest-rpc::rest-rpc INTERFACE "${vcpkg_rest_rpc_prefix_path}/include")
    target_link_libraries(unofficial::rest-rpc::rest-rpc INTERFACE asio::asio msgpack-cxx)
endif()

unset(vcpkg_rest_rpc_prefix_path)
