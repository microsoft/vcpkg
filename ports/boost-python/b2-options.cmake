set(BUILD_PYTHON_VERSIONS)

if("python2" IN_LIST FEATURES)
    # Find Python2 libraries. Can't use find_package here, but we already know where everything is
    file(GLOB VCPKG_PYTHON2_INCLUDE "${CURRENT_INSTALLED_DIR}/include/python2.*")
    set(VCPKG_PYTHON2_LIBS_RELEASE "${CURRENT_INSTALLED_DIR}/lib")
    set(VCPKG_PYTHON2_LIBS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib")
    string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" VCPKG_PYTHON2_VERSION "${VCPKG_PYTHON2_INCLUDE}")
    list(APPEND BUILD_PYTHON_VERSIONS "${VCPKG_PYTHON2_VERSION}")
endif()

# Find Python3 libraries. Can't use find_package here, but we already know where everything is
file(GLOB VCPKG_PYTHON3_INCLUDE "${CURRENT_INSTALLED_DIR}/include/python3.*")
set(VCPKG_PYTHON3_LIBS_RELEASE "${CURRENT_INSTALLED_DIR}/lib")
set(VCPKG_PYTHON3_LIBS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib")
string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" VCPKG_PYTHON3_VERSION "${VCPKG_PYTHON3_INCLUDE}")
list(APPEND BUILD_PYTHON_VERSIONS "${VCPKG_PYTHON3_VERSION}")

string(REPLACE ";" "," BUILD_PYTHON_VERSIONS "${BUILD_PYTHON_VERSIONS}")

list(APPEND B2_OPTIONS
    python=${BUILD_PYTHON_VERSIONS}
)
