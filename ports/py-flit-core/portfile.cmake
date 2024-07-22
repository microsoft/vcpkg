vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/flit
    REF c8ae08dc9f3f067feeec9dfd2c443db592f4d3d1
    SHA512 4f561b142bb97432d7815f8e0579b562ce5c7eec666f36d52f088adcdd1846337b89ca090ae9849feafc6beb49f7b59fdd11c2b4c730d7b8337729c76cd346d3
    HEAD_REF main
)

vcpkg_get_vcpkg_installed_python(VCPKG_PYTHON3_EXECUTABLE)
message(STATUS "Building dist with '${VCPKG_PYTHON3_EXECUTABLE}'!")
execute_process(COMMAND "${VCPKG_PYTHON3_EXECUTABLE}" "${SOURCE_PATH}/flit_core/build_dists.py"
  COMMAND_ERROR_IS_FATAL ANY
  #WORKING_DIRECTORY  "${wheeldir}"
)

file(GLOB wheel "${SOURCE_PATH}/flit_core/dist/*.whl")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE})
message(STATUS "Installing wheel!")
execute_process(COMMAND "${VCPKG_PYTHON3_EXECUTABLE}" "${SOURCE_PATH}/flit_core/bootstrap_install.py" "${wheel}" -i "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}"
  COMMAND_ERROR_IS_FATAL ANY
  #WORKING_DIRECTORY  "${wheeldir}"
)
message(STATUS "Finished installing wheel!")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "flit_core")
