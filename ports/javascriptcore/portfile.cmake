vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webkit/webkit
    REF WebKit-7616.1.27.211.1
    SHA512 aea5feb085f9adaa6efbbb840b2bdbc677c69c82c53c611ef9b527ae4ea2490a983dfdc55eb8aa471ab9975b748ea51d2cf9f2c853454904018ab8bb0ec77ad0
    HEAD_REF main
)

vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH "${RUBY}" DIRECTORY)
set(_path $ENV{PATH})
vcpkg_add_to_path("${RUBY_PATH}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
vcpkg_execute_required_process(
  COMMAND "${PYTHON3}" "${SOURCE_PATH}/Tools/Scripts/update-webkit-wincairo-libs.py"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME libjsc-${TARGET_TRIPLET}
)

vcpkg_add_to_path("${SOURCE_PATH}/WebKitLibraries/win/bin64")

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DPORT="WinCairo"
    -DCMAKE_BUILD_TYPE=Release
    -G Ninja
    -DDEVELOPER_MODE=ON
    -DENABLE_EXPERIMENTAL_FEATURES=ON
    -DWEBKIT_LIBRARIES_DIR=${SOURCE_PATH}/WebKitLibraries/win
)

vcpkg_cmake_build(
  TARGET JavaScriptCore
)
vcpkg_cmake_install()
# file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libogg" RENAME copyright)

# Restore original path
set(ENV{PATH} ${_path})
