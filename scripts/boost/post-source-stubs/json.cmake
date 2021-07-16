# see https://github.com/boostorg/json/issues/556 fore more details
vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile" "import ../../config/checks/config" "import config/checks/config")
vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile" "\n      <library>/boost//container/<warnings-as-errors>off" "")

vcpkg_replace_string("${SOURCE_PATH}/Jamfile" "import ../config/checks/config" "import build/config/checks/config")
vcpkg_replace_string("${SOURCE_PATH}/Jamfile" "..//check_basic_alignas" "..//..//..//check_basic_alignas")

file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/build/config")
