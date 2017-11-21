function(convert_to_utf8 FILE_PATH)
  execute_process(COMMAND powershell "${CMAKE_CURRENT_LIST_DIR}/convert-to-utf8.ps1 -filePath '${FILE_PATH}'")
endfunction(convert_to_utf8 FILE_PATH)