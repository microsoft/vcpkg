vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/sdformat
    REF "sdformat13_${VERSION}"
    SHA512 adc555527aadaede84d6fde11555bf4872028d9e895fc47c89f4077452fde9a52b233d60d0cbff5a098e261c7810aa2dc38a6275ec9f37ba4d0161af98e2aade
    HEAD_REF sdf13
    PATCHES
        no-absolute.patch
        cmake-config.patch
        fix-find-urdfdom.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DRUBY=${RUBY}"
        -DBUILD_TESTING=OFF
        -DSKIP_PYBIND11=ON
        -DUSE_INTERNAL_URDF=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat13")
vcpkg_fixup_pkgconfig()

# fix dependency urdfdom
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/sdformat13-config.cmake" "find_package(TINYXML2" [[
if (NOT TARGET GzURDFDOM::GzURDFDOM)
    find_package(urdfdom CONFIG ${gz_package_quiet} ${gz_package_required})
    add_library(GzURDFDOM::GzURDFDOM INTERFACE IMPORTED)
    target_link_libraries(GzURDFDOM::GzURDFDOM
        INTERFACE
        urdfdom::urdfdom_model
        urdfdom::urdfdom_world
        urdfdom::urdfdom_sensor
        urdfdom::urdfdom_model_state
    )
endif()
find_package(TINYXML2]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
