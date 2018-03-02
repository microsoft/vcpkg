include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF v0.13.68
    SHA512 e8a9976242acc04064ec239b9b929228370a946e5bd37092adcc1bda14605710a3850d39795d1937b609d1ab9a9a1998152f8c88b2dccc387ac6ec774d9cfce9
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
