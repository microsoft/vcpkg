string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/${PORT}
    REF ${PORT}${VERSION_MAJOR}_${VERSION}
    SHA512 10c56fab3957fff759c3ff7db401e162c5d353221e3895617182031be41e10a5234607fb7d1afb0ec453f3e1f20ddcc36b8488ed3d1cc2d1d0e915fc3a74ddbd
    HEAD_REF sdf${VERSION_MAJOR}
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
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}${VERSION_MAJOR}")
vcpkg_fixup_pkgconfig()

# preserve the original port behavior
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}/")

# fix dependency urdfdom
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}/${PORT}${VERSION_MAJOR}-config.cmake" "find_package(TINYXML2" [[
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
