string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/${PORT}
    REF ${PORT}${VERSION_MAJOR}_${VERSION}
    SHA512 8e3bd85b5e567286110ed53ef4b800922a2c4df21aa61d4591141f6fb02d9629d8be0fb3e8bb9fb1e02c95e8064b381f1349d086e1e991aa91b512cff94cdf06
    HEAD_REF sdf${VERSION_MAJOR}
    PATCHES
        no-absolute.patch
        cmake-config.patch
)

# Python is required to generate the EmbeddedSdf.cc file, which contains all the supported SDF
# descriptions in a map of strings. The parser.cc file uses EmbeddedSdf.hh.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DSKIP_PYBIND11=ON
        -DUSE_INTERNAL_URDF=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
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
