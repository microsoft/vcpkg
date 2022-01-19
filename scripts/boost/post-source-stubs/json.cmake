file(READ "${SOURCE_PATH}/build/Jamfile" _contents)
string(REPLACE "import ../../config/checks/config" "import ../config/checks/config" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
