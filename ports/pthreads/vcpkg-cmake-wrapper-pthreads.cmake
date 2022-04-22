_find_package(PThreads4W)
set(pthreads_INCLUDE_DIR "${PThreads4W_INCLUDE_DIR}")
set(pthreads_LIBRARY "${PThreads4W_LIBRARY}")
set(pthreads_LIBRARIES "${PThreads4W_LIBRARY}")
set(pthreads_VERSION "${PThreads4W_VERSION}")

if(PThreads4W_FOUND)
  set(pthreads_FOUND TRUE)
endif()
