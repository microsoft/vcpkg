find_program(HDIUTIL NAMES hdiutil REQUIRED)
set(dmg_path "NOTFOUND" CACHE FILEPATH "Where to find the DMG")
set(output_dir "output_dir" CACHE FILEPATH "Where to put the packages")

if(NOT EXISTS "${dmg_path}")
    message(FATAL_ERROR "'dmg_path' (${dmg_path}) does not exist.")
endif()
if(NOT IS_DIRECTORY "${output_dir}")
    message(FATAL_ERROR "'output_dir' (${output_dir}) is not a directory.")
endif()

execute_process(
    COMMAND mktemp -d
    RESULT_VARIABLE mktemp_result
    OUTPUT_VARIABLE mount_point
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT mktemp_result STREQUAL "0")
    message(FATAL_ERROR "mktemp -d failed: ${mktemp_result}")
elseif(NOT IS_DIRECTORY "${mount_point}")
    message(FATAL_ERROR "'mount_point' (${mount_point}) is not a directory.")
endif()

execute_process(
    COMMAND "${HDIUTIL}" attach "${dmg_path}" -mountpoint "${mount_point}" -readonly
    RESULT_VARIABLE mount_result
)
if(mount_result STREQUAL "0")
    set(dmg_packages_dir "${mount_point}/bootstrapper.app/Contents/Resources/packages")
    file(GLOB packages
        "${dmg_packages_dir}/intel.oneapi.mac.mkl.devel,*"
        "${dmg_packages_dir}/intel.oneapi.mac.mkl.runtime,*"
        "${dmg_packages_dir}/intel.oneapi.mac.mkl.product,*"
        "${dmg_packages_dir}/intel.oneapi.mac.openmp,*"
    )
    # Using execute_process to avoid direct errors
    execute_process(
        COMMAND cp -R ${packages} "${output_dir}/"
        RESULT_VARIABLE copy_result
    )
endif()
execute_process(
    COMMAND "${HDIUTIL}" detach "${mount_point}"
    RESULT_VARIABLE unmount_result
)

if(NOT mount_result STREQUAL "0")
    message(FATAL_ERROR "Mounting ${dmg_path} failed: ${mount_result}")
elseif(NOT copy_result STREQUAL "0")
    message(FATAL_ERROR "Coyping packages failed: ${copy_result}")
elseif(NOT unmount_result STREQUAL "0")
    message(FATAL_ERROR "Unounting ${dmg_path} failed: ${unmount_result}")
endif()
