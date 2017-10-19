function(vcpkg_acquire_depot_tools PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/depot_tools)
  set(URL "https://storage.googleapis.com/chrome-infra/depot_tools.zip")
  set(ARCHIVE "depot_tools.zip")
  set(STAMP "initialized-depot-tools.stamp")
  set(downloaded_file_path ${DOWNLOADS}/${ARCHIVE})

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")

    message(STATUS "Acquiring Depot Tools...")

    if(EXISTS ${downloaded_file_path})
      message(STATUS "Using cached ${downloaded_file_path}")
    else()
      if(_VCPKG_NO_DOWNLOADS)
        message(FATAL_ERROR "Downloads are disabled, but '${downloaded_file_path}' does not exist.")
      endif()
      file(DOWNLOAD ${URL} ${downloaded_file_path} STATUS download_status)
      list(GET download_status 0 status_code)
      if (NOT "${status_code}" STREQUAL "0")
        message(STATUS "Downloading ${URL}... Failed. Status: ${download_status}")
        file(REMOVE ${downloaded_file_path})
        set(download_success 0)
      else()
        message(STATUS "Downloading ${URL}... OK")
        set(download_success 1)
      endif()

      if (NOT download_success)
        message(FATAL_ERROR
          "\n"
          "    Failed to download file.\n"
        "    Add mirrors or submit an issue at https://github.com/Microsoft/vcpkg/issues\n")
      endif()
    endif()


    file(REMOVE_RECURSE ${TOOLPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring Depot Tools... OK")
  endif()
  set(${PATH_TO_ROOT_OUT} ${TOOLPATH} PARENT_SCOPE)
endfunction()
