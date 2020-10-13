file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)

string(REPLACE "import ../../config/checks/config" "import config/checks/config" _contents "${_contents}")

string(REPLACE "check-target-builds cxx11_moveable_fstreams" "check-target-builds ../check_movable_fstreams.cpp" _contents "${_contents}")
string(REPLACE "check-target-builds lfs_support" "check-target-builds ../check_lfs_support.cpp" _contents "${_contents}")

file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/build/config")

file(COPY "${SOURCE_PATH}/test/check_lfs_support.cpp" "${SOURCE_PATH}/test/check_movable_fstreams.cpp" DESTINATION "${SOURCE_PATH}/build/config")
