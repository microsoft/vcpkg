if("numa" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS numa=on)
endif()
