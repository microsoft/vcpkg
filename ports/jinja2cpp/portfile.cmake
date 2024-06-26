vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jinja2cpp/Jinja2Cpp
    REF "${VERSION}"
    SHA512 10fa5b6d8d64b33f078611f25ce4c1be325f98ce81cb03cf3af5cbbd2c3d5b29867245d68bf5bdb3edf9c8ef79577bb6eaa1c5b681dc314a81f6caeaca89b1f3
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JINJA2CPP_BUILD_SHARED)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DJINJA2CPP_BUILD_TESTS=OFF
    -DJINJA2CPP_STRICT_WARNINGS=OFF
    -DJINJA2CPP_BUILD_SHARED=${JINJA2CPP_BUILD_SHARED}
    -DCMAKE_DISABLE_FIND_PACKAGE_expected-lite=ON
    -DCMAKE_DISABLE_FIND_PACKAGE_variant-lite=ON
    -DCMAKE_DISABLE_FIND_PACKAGE_optional-lite=ON
    -DCMAKE_DISABLE_FIND_PACKAGE_string-view-lite=ON
    -DJINJA2CPP_DEPS_MODE=external
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/${PORT}")

file(RENAME "${CURRENT_PACKAGES_DIR}/lib/static/jinja2cpp.lib" "${CURRENT_PACKAGES_DIR}/lib/jinja2cpp.lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/static/jinja2cpp.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jinja2cpp.lib")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/jinja2cpp.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/jinja2cpp.pc")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/jinja2cpp.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/jinja2cpp.pc")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/static" "${CURRENT_PACKAGES_DIR}/lib/static")

file(INSTALL
    ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)