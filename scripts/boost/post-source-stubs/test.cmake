file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)
string(REPLACE "import ../../predef/check/predef" "import ../predef/check/predef" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-predef/check" DESTINATION "${SOURCE_PATH}/predef")
