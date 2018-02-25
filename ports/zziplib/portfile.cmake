include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF v0.13.62
    SHA512 e3dda9cfb7dadd44d3307d3ae0c706c68ef9d6434f78ed6fdb470defb03790e3c0c84d8e5149d3cff329d24627401b3ef2f0378bb3b2c3fcce89d7ae41627fb3
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/zziplib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zziplib/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/zziplib/copyright)
