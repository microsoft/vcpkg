function(vcpkg_acquire_depot_tools PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/depot_tools)
  set(URL "https://storage.googleapis.com/chrome-infra/depot_tools.zip")
  set(ARCHIVE "depot_tools.zip")
  set(STAMP "initialized-depot-tools.stamp")

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")
  message(STATUS "Acquiring Depot Tools...")
  file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE})
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
