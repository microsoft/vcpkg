_find_package(${ARGS})
find_package(Jasper REQUIRED)
if (Jasper_FOUND)
   list(APPEND LibRaw_LIBRARIES ${JASPER_LIBRARIES})
   list(APPEND LibRaw_r_LIBRARIES ${JASPER_LIBRARIES})
endif ()

