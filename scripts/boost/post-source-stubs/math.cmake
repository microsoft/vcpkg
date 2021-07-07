vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2" "import ../../config/checks/config" "import config/checks/config")
vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2" "check-target-builds ../config//has_gcc_visibility" "check-target-builds ../has_gcc_visibility.cpp")

file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/build/config")
file(COPY "${SOURCE_PATH}/config/has_gcc_visibility.cpp" DESTINATION "${SOURCE_PATH}/build/config")
file(COPY "${SOURCE_PATH}/config/has_gcc_visibility.cpp" DESTINATION "${SOURCE_PATH}/")
