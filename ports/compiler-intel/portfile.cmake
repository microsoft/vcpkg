set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(url "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/f07e32fa-b505-4b90-8a79-e328ce9ad9d6/intel-oneapi-hpc-toolkit-2025.0.0.822_offline.exe")

cmake_path(GET url FILENAME filename )
vcpkg_download_distfile(archive_path
    URLS "${url}"
    FILENAME "${filename}"
    SHA512 589b27f7d67487d87a24c25b651ffef79d4cf4e1dd55c128a50b27c63a8fa3f4675fa7412ebad1e7f6832bfd78a14a978d0889c23583f80b813be724ec9492e4
)

vcpkg_find_acquire_program(7Z)

set(out_dir "${CURRENT_BUILDTREES_DIR}/intel/compiler/")
file(MAKE_DIRECTORY "${out_dir}")

message(STATUS "Extracting ${archive_path} ....")
vcpkg_execute_in_download_mode(
                        COMMAND "${7Z}" x "${archive_path}" "-o${out_dir}" "-y" "-bso0" "-bsp0"
                        WORKING_DIRECTORY "${out_dir}"
                    )
message(STATUS "Finished extracting!")

#configure_file("${CURRENT_PACKAGES_DIR}/intel-extract/license.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/coypright" COPYONLY)
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
    "openmp"
    "compilers-common-runtime"
    "compilers-common"
    "ifort-compiler"
    "oneapi-common.vars"
    # "intel-pti-dev"
    # "ipp" # .devel .runtime cp
    # "mkl" # .devel .runtime
    # "mpi" # .devel .runtime
    "ocloc"
    # "tbb" # .devel .runtime
    )

list(TRANSFORM packages PREPEND "intel.oneapi.win.")

string(REPLACE "." "\\." package_regex "${packages}")
list(JOIN package_regex "|" package_regex)

file(GLOB extracted_folders LIST_DIRECTORIES true "${out_dir}/packages/*")
file(GLOB extracted_files LIST_DIRECTORIES false "${out_dir}/packages/*")
list(REMOVE_ITEM extracted_folders "${extracted_files}")

list(FILTER extracted_folders INCLUDE REGEX "(${package_regex}),")

foreach(package_folder IN LISTS extracted_folders)
    cmake_path(GET package_folder STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem} ....")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_folder}/cupPayload.cup"
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )
    message(STATUS "Finsihed extracting ${packstem}!")

endforeach()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/compiler")
file(RENAME "${CURRENT_PACKAGES_DIR}/_installdir/" "${CURRENT_PACKAGES_DIR}/compiler/intel")
file(REMOVE
        "${CURRENT_PACKAGES_DIR}/filelist.json"
        "${CURRENT_PACKAGES_DIR}/filelist.json.sig"
    )

configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-msvc-env.cmake" "${CURRENT_PACKAGES_DIR}/env-setup/intel-msvc-env.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-msvc-env.ps1" "${CURRENT_PACKAGES_DIR}/env-setup/intel-msvc-env.ps1" @ONLY)

