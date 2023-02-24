set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_download_distfile(archive_path
    URLS "https://registrationcenter-download.intel.com/akdlm/irc_nas/18578/w_HPCKit_p_2022.1.3.145_offline.exe"
    FILENAME "w_HPCKit_p_2022.1.3.145_offline.exe" 
    SHA512 703f525002d07b75dcfbfd337bf6b8621f13674a45d5ad909d34d0117ea992f16fc4fa96a16d8c7ea39cc79a063b20d0c0446c4bd9e8c0d9f2f2ca91cee7eeae
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
vcpkg_execute_in_download_mode(
                        COMMAND "${7Z}" x "${archive_path}" "-o${CURRENT_PACKAGES_DIR}/intel-extract" "-y" "-bso0" "-bsp0"
                        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
                    )

configure_file("${CURRENT_PACKAGES_DIR}/intel-extract/license.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/coypright" COPYONLY)
# vcpkg_execute_in_download_mode(
                        # COMMAND "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/bootstrapper.exe" 
                            # "-s " "--action install" 
                            # "--components=intel.oneapi.win.cpp-compiler:intel.oneapi.win.ifort-compiler" 
                            # "--eula=accept" 
                            # "--install-dir=${CURRENT_PACKAGES_DIR}/manual-tools/intel"
                            # "--intel-sw-improvement-program-consent=decline"
                            # "-p=NEED_VS2017_INTEGRATION=0" "-p=NEED_VS2019_INTEGRATION=0" "-p=NEED_VS2022_INTEGRATION=0" 
                            # "--log-dir=${CURRENT_BUILDTREES_DIR}"
                        # WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
                    # )

set(packages 
    "intel.oneapi.win.openmp,v=2022.0.3-3747/oneapi-comp-openmp-for-installer_p_2022.0.3.3747.msi"
    "intel.oneapi.win.compilers-common-runtime,v=2022.0.3-3747/oneapi-comp-common-runtime-for-installer_p_2022.0.3.3747.msi"
    "intel.oneapi.win.compilers-common,v=2022.0.3-3747/oneapi-comp-common-for-installer_p_2022.0.3.3747.msi"
    "intel.oneapi.win.ifort-compiler,v=2022.0.3-3747/oneapi-comp-f-for-installer_p_2022.0.3.3747.msi"
    "intel.oneapi.win.oneapi-common.vars,v=2022.0.1-126/oneapi-common-vars-for-installer_p_2022.0.1.126.msi"
    )
foreach(pack IN LISTS packages)
    set(archive_path "${CURRENT_PACKAGES_DIR}/intel-extract/packages/${pack}")
    cmake_path(GET pack STEM LAST_ONLY packstem)
    cmake_path(NATIVE_PATH archive_path archive_path_native)
    set(output_path "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}") # vcpkg.cmake adds everything in /tools to CMAKE_PROGRAM_PATH. That is not desired 
    file(MAKE_DIRECTORY "${output_path}")
        vcpkg_execute_in_download_mode(
                        COMMAND "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-lessmsi/lessmsi.exe" x "${archive_path_native}" # Using output_path here does not work in bash
                        WORKING_DIRECTORY "${output_path}" 
                        OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-out.log"
                        ERROR_FILE "${CURRENT_BUILDTREES_DIR}/lessmsi-${TARGET_TRIPLET}-err.log"
                        RESULT_VARIABLE error_code
                    )
    file(COPY "${output_path}/${packstem}/SourceDir/" DESTINATION "${output_path}")
    file(REMOVE_RECURSE "${output_path}/${packstem}")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/Intel/Compiler/12.0/setvars.bat" "componentArray[default]=latest" "componentArray[default]=2022.0.3") # The latest symlink is not created
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/intel-extract")