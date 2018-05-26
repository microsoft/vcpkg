cmake_minimum_required(VERSION 3.9.0)

project(pthreads)

set(PTHREAD_PUBLIC_HEADERS pthread.h sched.h semaphore.h)

set(PTHREAD_SHARED_SOURCES
  autostatic.c
  barrier.c
  cancel.c
  cleanup.c
  condvar.c
  create.c
  dll.c
  errno.c
  exit.c
  fork.c
  global.c
  misc.c
  mutex.c
  nonportable.c
  private.c
  rwlock.c
  sched.c
  semaphore.c
  signal.c
  spin.c
  sync.c
  tsd.c
  attr.C
)
set(PTHREAD_STATIC_SOURCES
  autostatic.c
  cleanup.c
  create.c
  dll.c
  errno.c
  fork.c
  global.c
  pthread_attr_destroy.c
  pthread_attr_getdetachstate.c
  pthread_attr_getinheritsched.c
  pthread_attr_getschedparam.c
  pthread_attr_getschedpolicy.c
  pthread_attr_getscope.c
  pthread_attr_getstackaddr.c
  pthread_attr_getstacksize.c
  pthread_attr_init.c
  pthread_attr_setdetachstate.c
  pthread_attr_setinheritsched.c
  pthread_attr_setschedparam.c
  pthread_attr_setschedpolicy.c
  pthread_attr_setscope.c
  pthread_attr_setstackaddr.c
  pthread_attr_setstacksize.c
  pthread_barrier_destroy.c
  pthread_barrier_init.c
  pthread_barrier_wait.c
  pthread_barrierattr_destroy.c
  pthread_barrierattr_getpshared.c
  pthread_barrierattr_init.c
  pthread_barrierattr_setpshared.c
  pthread_cancel.c
  pthread_cond_destroy.c
  pthread_cond_init.c
  pthread_cond_signal.c
  pthread_cond_wait.c
  pthread_condattr_destroy.c
  pthread_condattr_getpshared.c
  pthread_condattr_init.c
  pthread_condattr_setpshared.c
  pthread_delay_np.c
  pthread_detach.c
  pthread_equal.c
  pthread_exit.c
  pthread_getconcurrency.c
  pthread_getschedparam.c
  pthread_getspecific.c
  pthread_getunique_np.c
  pthread_getw32threadhandle_np.c
  pthread_join.c
  pthread_key_create.c
  pthread_key_delete.c
  pthread_kill.c
  pthread_mutex_consistent.c
  pthread_mutex_destroy.c
  pthread_mutex_init.c
  pthread_mutex_lock.c
  pthread_mutex_timedlock.c
  pthread_mutex_trylock.c
  pthread_mutex_unlock.c
  pthread_mutexattr_destroy.c
  pthread_mutexattr_getkind_np.c
  pthread_mutexattr_getpshared.c
  pthread_mutexattr_getrobust.c
  pthread_mutexattr_gettype.c
  pthread_mutexattr_init.c
  pthread_mutexattr_setkind_np.c
  pthread_mutexattr_setpshared.c
  pthread_mutexattr_setrobust.c
  pthread_mutexattr_settype.c
  pthread_num_processors_np.c
  pthread_once.c
  pthread_rwlock_destroy.c
  pthread_rwlock_init.c
  pthread_rwlock_rdlock.c
  pthread_rwlock_tryrdlock.c
  pthread_rwlock_trywrlock.c
  pthread_rwlock_unlock.c
  pthread_rwlock_wrlock.c
  pthread_rwlockattr_destroy.c
  pthread_rwlockattr_getpshared.c
  pthread_rwlockattr_init.c
  pthread_rwlockattr_setpshared.c
  pthread_self.c
  pthread_setcancelstate.c
  pthread_setcanceltype.c
  pthread_setconcurrency.c
  pthread_setschedparam.c
  pthread_setspecific.c
  pthread_spin_destroy.c
  pthread_spin_init.c
  pthread_spin_lock.c
  pthread_spin_trylock.c
  pthread_spin_unlock.c
  pthread_testcancel.c
  pthread_timechange_handler_np.c
  pthread_win32_attach_detach_np.c
  ptw32_calloc.c
  ptw32_callUserDestroyRoutines.c
  ptw32_cond_check_need_init.c
  ptw32_getprocessors.c
  ptw32_is_attr.c
  ptw32_MCS_lock.c
  ptw32_mutex_check_need_init.c
  ptw32_new.c
  ptw32_processInitialize.c
  ptw32_processTerminate.c
  ptw32_relmillisecs.c
  ptw32_reuse.c
  ptw32_rwlock_check_need_init.c
  ptw32_semwait.c
  ptw32_spinlock_check_need_init.c
  ptw32_threadDestroy.c
  ptw32_threadStart.c
  ptw32_throw.c
  ptw32_timespec.c
  ptw32_tkAssocCreate.c
  ptw32_tkAssocDestroy.c
  sched_get_priority_max.c
  sched_get_priority_min.c
  sched_getscheduler.c
  sched_setscheduler.c
  sched_yield.c
  sem_close.c
  sem_destroy.c
  sem_getvalue.c
  sem_init.c
  sem_open.c
  sem_post_multiple.c
  sem_post.c
  sem_timedwait.c
  sem_trywait.c
  sem_unlink.c
  sem_wait.c
  signal.c
  w32_CancelableWait.c
)



option(PTW32_ARCH  "x32")
add_definitions(-DPTW32_ARCH=${PTW32_ARCH} -DPTW32_RC_MSC -DHAVE_PTW32_CONFIG_H -D_TIMESPEC_DEFINED)

if(BUILD_SHARED_LIBS)
  set(PTHREAD_SOURCES  ${PTHREAD_SHARED_SOURCES})
  add_definitions(-DPTW32_BUILD)
else()
  set(PTHREAD_SOURCES  ${PTHREAD_STATIC_SOURCES})
  add_definitions(-DPTW32_STATIC_LIB)
endif()


if(PTHREADS_BUILD_CPP)
  set(PTHREADS_EXCEPTION_SCHEME CE)
  add_definitions(/__CLEANUP_CXX)
elseif(PTHREADS_BUILD_SEH)
  set(PTHREADS_EXCEPTION_SCHEME SE)
  add_definitions(/__CLEANUP_SEH)
else()
  set(PTHREADS_EXCEPTION_SCHEME C)
endif()

set(PTHREADS_COMPATIBILITY_VERSION 2)
set(CMAKE_DEBUG_POSTFIX d)
set(PTHREADS_COMPILER V)

set(PTHREADS_LIBRARY "pthreads${PTHREADS_COMPILER}${PTHREADS_EXCEPTION_SCHEME}${PTHREADS_COMPATIBILITY_VERSION}")

include_directories(.)

add_library(${PTHREADS_LIBRARY} ${PTHREAD_SOURCES})

install(
  TARGETS  ${PTHREADS_LIBRARY}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${PTHREAD_PUBLIC_HEADERS} DESTINATION include)
endif()
