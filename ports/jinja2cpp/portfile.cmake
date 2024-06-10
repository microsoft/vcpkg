vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cheaterdev/Jinja2Cpp
    REF "${VERSION}"
    SHA512 345800e8b361186325b1f479154fdf0fa234029fb9bfcbce4540f1ea5a9a3ab8f098db4969f73a2c5996703e3ad12be4b29e51fde49cf4a5bc6fcbd8f88dc976
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

find_library(JINJA2CPP_REL NAMES jinja2cpp PATHS "${CURRENT_PACKAGES_DIR}/lib/" NO_DEFAULT_PATH) 
find_library(JINJA2CPP_DBG NAMES jinja2cpp PATHS "${CURRENT_PACKAGES_DIR}/debug/lib/" NO_DEFAULT_PATH) 

if(JINJA2CPP_REL)
    file(RENAME "${JINJA2CPP_REL}" "${CURRENT_PACKAGES_DIR}/lib/jinja2cpp.lib")
endif()

if(JINJA2CPP_DBG)
    file(RENAME "${JINJA2CPP_DBG}" "${CURRENT_PACKAGES_DIR}/debug/lib/jinja2cpp.lib")
endif()

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