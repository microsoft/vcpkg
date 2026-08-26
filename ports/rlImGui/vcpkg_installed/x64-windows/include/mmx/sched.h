/*
    sched.h - zlib - Doug Binks, Micha Mettke

ABOUT:
    This is a permissively licensed ANSI C Task Scheduler for
    creating parallel programs. Note - this is a pure ANSI C single header
    conversion of Doug Binks enkiTS library (https://github.com/dougbinks/enkiTS).

    Project Goals
    - ANSI C: Designed to be easy to embed into other languages
    - Embeddable: Designed as a single header library to be easy to embed into your code. 
    - Lightweight: Designed to be lean so you can use it anywhere easily, and understand it.
    - Fast, then scalable: Designed for consumer devices first, so performance on a low number of threads is important, followed by scalability.
    - Braided parallelism: Can issue tasks from another task as well as from the thread which created the Task System.
    - Up-front Allocation friendly: Designed for zero allocations during scheduling.

DEFINE:
    SCHED_IMPLEMENTATION
        Generates the implementation of the library into the included file.
        If not provided the library is in header only mode and can be included
        in other headers or source files without problems. But only ONE file
        should hold the implementation.

    SCHED_STATIC
        The generated implementation will stay private inside the implementation
        file and all internal symbols and functions will only be visible inside
        that file.

    SCHED_ASSERT
    SCHED_USE_ASSERT
        If you define SCHED_USE_ASSERT without defining ASSERT sched.h
        will use assert.h and assert(). Otherwise it will use your assert
        method. If you do not define SCHED_USE_ASSERT no additional checks
        will be added. This is the only C standard library function used
        by sched.

    SCHED_MEMSET
        You can define this to 'memset' or your own memset replacement.
        If not, sched.h uses a naive (maybe inefficent) implementation.

    SCHED_INT32
    SCHED_UINT32
    SCHED_UINT_PTR
        If your compiler is C99 you do not need to define this.
        Otherwise, sched will try default assignments for them
        and validate them at compile time. If they are incorrect, you will
        get compile errors and will need to define them yourself.

    SCHED_SPIN_COUNT_MAX
        You can change this to set the maximum number of spins for worker
        threads to stop looking for work and go into a sleeping state.

    SCHED_PIPE_SIZE_LOG2
        You can change this to set the size of each worker thread pipe.
        The value is in power of two and needs to smaller than 32 otherwise
        the atomic integer type will overflow.


LICENSE: (zlib)
    Copyright (c) 2016 Doug Binks

    This software is provided 'as-is', without any express or implied
    warranty.  In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1.  The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software
        in a product, an acknowledgment in the product documentation would be
        appreciated but is not required.
    2.  Altered source versions must be plainly marked as such, and must not be
        misrepresented as being the original software.
    3.  This notice may not be removed or altered from any source distribution.

CONTRIBUTORS:
    Doug Binks (implementation)
    Micha Mettke (single header ANSI C conversion)

EXAMPLES:*/
#if 0
    static void parallel_task(void *pArg, struct scheduler *s, struct sched_task_partition p, sched_uint thread_num) {
        /* Do something here, cann issue additional tasks into the scheduler */
    }

    int main(int argc, const char **argv)
    {
        void *memory;
        sched_size needed_memory;

        struct scheduler sched;
        scheduler_init(&sched, &needed_memory, SCHED_DEFAULT, 0);
        memory = calloc(needed_memory, 1);
        scheduler_start(&sched, memory);
        {
            struct sched_task task;
            scheduler_add(&sched, &task, parallel_task, NULL, 1, 1);
            scheduler_join(&sched, &task);
        }
        scheduler_stop(&sched, 1);
        free(memory);
    }
#endif
 /* ===============================================================
 *
 *                          HEADER
 *
 * =============================================================== */
#ifndef SCHED_H_
#define SCHED_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SCHED_STATIC
#define SCHED_API static
#else
#define SCHED_API extern
#endif

#if defined _MSC_VER || (defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 19901L))
  #include <stdint.h>
  #ifndef SCHED_UINT32
    #define SCHED_UINT32 uint32_t
  #endif
  #ifndef SCHED_INT32
    #define SCHED_INT32 int32_t
  #endif
  #ifndef SCHED_UINT_PTR
    #define SCHED_UINT_PTR uintptr_t
  #endif
#else
  #ifndef SCHED_UINT32
    #define SCHED_UINT32 unsigned int
  #endif
  #ifndef SCHED_INT32
    #define SCHED_INT32 int
  #endif
  #ifndef SCHED_UINT_PTR
    #define SCHED_UINT_PTR unsigned long
  #endif
#endif
typedef unsigned char sched_byte;
typedef SCHED_UINT32 sched_uint;
typedef SCHED_INT32 sched_int;
typedef SCHED_UINT_PTR sched_size;
typedef SCHED_UINT_PTR sched_ptr;

struct scheduler;
struct sched_task_partition {
    sched_uint start;
    sched_uint end;
};
typedef void(*sched_run)(void*, struct scheduler*, struct sched_task_partition, sched_uint thread_num);
struct sched_task {
    void *userdata;
    /* custum userdata to use in callback userdata */
    sched_run exec;
    /* function working on the task owner structure */
    sched_uint size;
    /* number of elements inside the set */
    sched_uint min_range;
    /* minimum size of range when splitting a task set into partitions.
     * This should be set to a value which results in computation effort of at
     * least 10k clock cycles to minimiye task scheduler overhead.
     * NOTE: The last partition will be smaller than min_range if size is not a
     * multiple of min_range (lit.: grain size) */
    /* --------- INTERNAL ONLY -------- */
    volatile sched_int run_count;
    sched_uint range_to_run;
};
#define sched_task_done(t) (!(t)->run_count)

typedef void (*sched_profiler_callback_f)(void*, sched_uint thread_id);
struct sched_profiling {
    void *userdata;
    /* from the user provided data used in each callback */
    sched_profiler_callback_f thread_start;
    /* callback called as soon as a thread starts working */
    sched_profiler_callback_f thread_stop;
    /* callback called when as a thread is finished */
    sched_profiler_callback_f wait_start;
    /* callback called if a thread begins waiting */
    sched_profiler_callback_f wait_stop;
    /* callback called if a thread is woken up */
};

struct sched_semaphore;
struct sched_thread_args;
struct sched_pipe;

struct scheduler {
    struct sched_pipe *pipes;
    /* pipe for every worker thread */
    unsigned int threads_num;
    /* number of worker threads */
    struct sched_thread_args *args;
    /* data used in the os thread callback */
    void *threads;
    /* os threads array  */
    volatile sched_int running;
    /* flag whether the scheduler is running  */
    volatile sched_int thread_running;
    /* number of thread that are currently running */
    volatile sched_int thread_waiting;
    /* number of thread that are currently active */
    unsigned partitions_num;
    unsigned partitions_init_num;
    /* divider for the array handled by a task */
    struct sched_semaphore *new_task_semaphore;
    /* os event to signal work */
    sched_int have_threads;
    /* flag whether the os threads have been created */
    struct sched_profiling profiling;
    /* profiling callbacks  */
    sched_size memory;
    /* memory size */
};

#define SCHED_DEFAULT (-1)
SCHED_API void scheduler_init(struct scheduler*, sched_size *needed_memory,
                                sched_int thread_count, const struct sched_profiling*);
/*  this function clears the scheduler and calculates the needed memory to run
    Input:
    -   number of os threads to create inside the scheduler (or SCHED_DEFAULT for number of cpu cores)
    -   optional profiling callbacks for profiler (NULL if not wanted)
    Output:
    -   needed memory for the scheduler to run
*/
SCHED_API void scheduler_start(struct scheduler*, void *memory);
/*  this function starts running the scheduler and creates the previously set
 *  number of threads-1, which is sufficent to fill the system by
 *  including the main thread. Start can be called multiple times - it will wait
 *  for the completion before re-initializing.
    Input:
    -   previously allocated memory to run the scheduler with
*/
SCHED_API void scheduler_add(struct scheduler*, struct sched_task*, sched_run func, void *pArg, sched_uint size, sched_uint min_range);
/*  this function adds a task into the scheduler to execute and directly returns
 *  if the pipe is not full. Otherwise the task is run directly. Should only be
 *  called from main thread or within task handler.
    Input:
    -   function to execute to process the task
    -   userdata to call the execution function with
    -   array size that will be divided over multible threads
    Output:
    -   task handle used to wait for the task to finish or check if done. Needs
        to be persistent over the process of the task
*/
SCHED_API void scheduler_join(struct scheduler*, struct sched_task*);
/*  this function waits for a previously started task to finish. Should only be
 *  called from thread which created the task scheduler, or within a task
 *  handler. if called with NULL it will try to run task and return if none
 *  available.
    Input:
    -   previously started task to wait until it is finished
*/
SCHED_API void scheduler_wait(struct scheduler*);
/*  this function waits for all task inside the scheduler to finish. Not
 *  guaranteed to work unless we know we are in a situation where task aren't
 *  being continuosly added. */
SCHED_API void scheduler_stop(struct scheduler*, int doWait);
/*  this function waits for all task inside the scheduler to finish and stops
 *  all threads and shuts the scheduler down. Not guaranteed to work unless we
 *  are in a situation where task aren't being continuosly added.
    Input:
    -   boolean flag specifing to wait for all task to finish before stopping */

#ifdef __cplusplus
}
#endif
#endif /* SCHED_H_ */

/* ===============================================================
 *
 *                          IMPLEMENTATION
 *
 * ===============================================================*/
#ifdef SCHED_IMPLEMENTATION

/* windows requires Windows.h even if you use mingw */
#if defined(_WIN32) || (defined(__MINGW32__) || defined(__MINGW64__))
    #define WIN32_LEAN_AND_MEAN
    #include <Windows.h>
#endif

/* make sure atomic and pointer types have correct size */
typedef int sched__check_ptr_size[(sizeof(void*) == sizeof(SCHED_UINT_PTR)) ? 1 : -1];
typedef int sched__check_ptr_uint32[(sizeof(sched_uint) == 4) ? 1 : -1];
typedef int sched__check_ptr_int32[(sizeof(sched_int) == 4) ? 1 : -1];

#ifdef SCHED_USE_ASSERT
#ifndef SCHED_ASSERT
#include <assert.h>
#define SCHED_ASSERT(expr) assert(expr)
#endif
#else
#define SCHED_ASSERT(expr)
#endif

#define SCHED_INTERN static
#define SCHED_GLOBAL static
#define SCHED_STORAGE static

#ifdef __cplusplus
/* C++ hates the C align of makro form so have to resort to templates */
template<typename T> struct sched_alignof;
template<typename T, int size_diff> struct sched_helper{enum {value = size_diff};};
template<typename T> struct sched_helper<T,0>{enum {value = sched_alignof<T>::value};};
template<typename T> struct sched_alignof{struct Big {T x; char c;}; enum {
    diff = sizeof(Big) - sizeof(T), value = sched_helper<Big, diff>::value};};
#define SCHED_ALIGNOF(t) (sched_alignof<t>::value);
#else
#define SCHED_ALIGNOF(t) ((char*)(&((struct {char c; t _h;}*)0)->_h) - (char*)0)
#endif

/* Pointer to Integer type conversion for pointer alignment */
#if defined(__PTRDIFF_TYPE__) /* This case should work for GCC*/
# define SCHED_UINT_TO_PTR(x) ((void*)(__PTRDIFF_TYPE__)(x))
# define SCHED_PTR_TO_UINT(x) ((sched_size)(__PTRDIFF_TYPE__)(x))
#elif !defined(__GNUC__) /* works for compilers other than LLVM */
# define SCHED_UINT_TO_PTR(x) ((void*)&((char*)0)[x])
# define SCHED_PTR_TO_UINT(x) ((sched_size)(((char*)x)-(char*)0))
#elif defined(SCHED_USE_FIXED_TYPES) /* used if we have <stdint.h> */
# define SCHED_UINT_TO_PTR(x) ((void*)(uintptr_t)(x))
# define SCHED_PTR_TO_UINT(x) ((uintptr_t)(x))
#else /* generates warning but works */
# define SCHED_UINT_TO_PTR(x) ((void*)(x))
# define SCHED_PTR_TO_UINT(x) ((sched_size)(x))
#endif

/* Pointer math*/
#define SCHED_PTR_ADD(t, p, i) ((t*)((void*)((sched_byte*)(p) + (i))))
#define SCHED_ALIGN_PTR(x, mask)\
    (SCHED_UINT_TO_PTR((SCHED_PTR_TO_UINT((sched_byte*)(x) + (mask-1)) & ~(mask-1))))

/* Helper */
#define SCHED_UNUSED(x) ((void)x)
#define SCHED_MIN(a,b) (((a)<(b))?(a):(b))
#define SCHEDULER_MAX(a,b) (((a)>(b))?(a):(b))

#ifndef SCHED_MEMSET
#define SCHED_MEMSET sched_memset
#endif

SCHED_INTERN void
sched_memset(void *ptr, sched_int c0, sched_size size)
{
    #define word unsigned
    #define wsize sizeof(word)
    #define wmask (wsize - 1)
    unsigned char *dst = (unsigned char*)ptr;
    unsigned long long c = 0;
    sched_size t = 0;

    if ((c = (unsigned char)c0) != 0) {
        c = (c << 8) | c; /* at least 16-bits  */
        if (sizeof(unsigned int) > 2)
            c = (c << 16) | c; /* at least 32-bits*/
        if (sizeof(unsigned int) > 4)
            c = (c << 32) | c; /* at least 64-bits*/
    }

    /* to small of a word count */
    dst = (unsigned char*)ptr;
    if (size < 3 * wsize) {
        while (size--) *dst++ = (unsigned char)c0;
        return;
    }

    /* align destination */
    if ((t = SCHED_PTR_TO_UINT(dst) & wmask) != 0) {
        t = wsize -t;
        size -= t;
        do {
            *dst++ = (unsigned char)c0;
        } while (--t != 0);
    }

    /* fill word */
    t = size / wsize;
    do {
        *(word*)((void*)dst) = c;
        dst += wsize;
    } while (--t != 0);

    /* fill trailing bytes */
    t = (size & wmask);
    if (t != 0) {
        do {
            *dst++ = (unsigned char)c0;
        } while (--t != 0);
    }

    #undef word
    #undef wsize
    #undef wmask
}

#define sched_zero_struct(s) sched_zero_size(&s, sizeof(s))
#define sched_zero_array(p,n) sched_zero_size(p, (n) * sizeof((p)[0]))
SCHED_INTERN void
sched_zero_size(void *ptr, sched_size size)
{
    SCHED_MEMSET(ptr, 0, size);
}

/* ---------------------------------------------------------------
 *                          ATOMIC
 * ---------------------------------------------------------------*/
#if  defined(_WIN32) && !(defined(__MINGW32__) || defined(__MINGW64__))
    #include <intrin.h>
    void _ReadWriteBarrier();
    #pragma intrinsic(_ReadWriteBarrier)
    #pragma intrinsic(_InterlockedCompareExchange)
    #pragma intrinsic(_InterlockedExchangeAdd)
    #define SCHED_BASE_MEMORY_BARRIER_ACQUIRE() _ReadWriteBarrier()
    #define SCHED_BASE_MEMORY_BARRIER_RELEASE() _ReadWriteBarrier()
    #define SCHED_BASE_ALIGN(x) __declspec(align(x))
#else
    #define SCHED_BASE_MEMORY_BARRIER_ACQUIRE() __asm__ __volatile__("": : :"memory")
    #define SCHED_BASE_MEMORY_BARRIER_RELEASE() __asm__ __volatile__("": : :"memory")
    #define SCHED_BASE_ALIGN(x) __attribute__((aligned(x)))
#endif

SCHED_INTERN sched_uint
sched_atomic_cmp_swp(volatile sched_uint *dst, sched_uint swap, sched_uint cmp)
{
/* Atomically performs: if (*dst == swapTp){ *dst = swapTo;}
 * return old *dst (so if sucessfull return cmp) */
#if defined(_WIN32) && !(defined(__MINGW32__) || defined(__MINGW64__))
    /* assumes two's complement - unsigned /signed conversion leads to same bit pattern */
    return _InterlockedCompareExchange((volatile long*)dst, swap, cmp);
#else
    return __sync_val_compare_and_swap(dst, cmp, swap);
#endif
}

SCHED_INTERN sched_int
sched_atomic_add(volatile sched_int *dst, sched_int value)
{
/* Atomically performs: tmp = *dst: *dst += value; return tmp; */
#if defined(_WIN32) && !(defined(__MINGW32__) || defined(__MINGW64__))
    return _InterlockedExchangeAdd((long*)dst, value);
#else
    return (sched_int)__sync_add_and_fetch(dst, value);
#endif
}

/* ---------------------------------------------------------------
 *                          THREAD
 * ---------------------------------------------------------------*/
#if defined(_WIN32) && !(defined(__MINGW32__) || defined(__MINGW64__))
#define SCHED_THREAD_FUNC_DECL DWORD WINAPI
#define SCHED_THREAD_LOCAL __declspec(thread)

typedef HANDLE sched_thread;
struct sched_semaphore {
    HANDLE sem;
};
SCHED_INTERN sched_int
sched_thread_create(sched_thread *returnid, DWORD(WINAPI *StartFunc)(void*), void *arg)
{
    DWORD thread;
    *returnid = CreateThread(0,0, StartFunc, arg, 0, &thread);
    return *returnid != NULL;
}

SCHED_INTERN sched_int
sched_thread_term(sched_thread threadid)
{
    return CloseHandle(threadid) == 0;
}

SCHED_INTERN sched_uint
sched_num_hw_threads(void)
{
    SYSTEM_INFO sysinfo;
    GetSystemInfo(&sysinfo);
    return sysinfo.dwNumberOfProcessors;
}

SCHED_INTERN void
sched_semaphore_create(struct sched_semaphore *s)
{
    s->sem = CreateSemaphore(0,0,MAXLONG,0);
}

SCHED_INTERN void
sched_semaphore_close(struct sched_semaphore *s)
{
    CloseHandle(s->sem);
}

SCHED_INTERN void
sched_semaphore_wait(struct sched_semaphore *s)
{
    DWORD ret = WaitForSingleObject(s->sem, INFINITE);
    SCHED_ASSERT(ret != WAIT_FAILED);
}

SCHED_INTERN void
sched_semaphore_signal(struct sched_semaphore *s, int cnt)
{
    if (!cnt) return;
    ReleaseSemaphore(s->sem, cnt, 0);
}

#else
/* POSIX */
#include <pthread.h>
#if !(defined(__MINGW32__) || defined(__MINGW64__))
    #include <unistd.h>
    #include <time.h>
#endif

#define SCHED_THREAD_FUNC_DECL void*
#define SCHED_THREAD_LOCAL __thread
typedef pthread_t sched_thread;

SCHED_INTERN sched_int
sched_thread_create(sched_thread *returnid, void*(*StartFunc)(void*), void *arg)
{
    sched_int ret_val;
    SCHED_ASSERT(returnid);
    SCHED_ASSERT(StartFunc);
    ret_val = pthread_create(returnid, NULL, StartFunc, arg);
    return(ret_val == 0);
}

SCHED_INTERN sched_int
sched_thread_term(sched_thread threadid)
{
    pthread_cancel(threadid);
    return (pthread_join(threadid, NULL) == 0);
}

SCHED_INTERN sched_uint
sched_num_hw_threads(void)
{
#ifdef _WIN32
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    return si.dwNumberOfProcessors;
#else
    return (sched_uint)sysconf(_SC_NPROCESSORS_ONLN);
#endif
}

#if defined(__MACH__)
/* OS X does not have POSIX semaphores
 * see: https://developer.apple.com/library/content/documentation/Darwin/Conceptual/KernelProgramming/synchronization/synchronization.html */
#include <mach/mach.h>

struct sched_semaphore {
    semaphore_t sem;
};

SCHED_INTERN void
sched_semaphore_create(struct sched_semaphore *s)
{
    semaphore_create(mach_task_self(), &s->sem, SYNC_POLICY_FIFO, 0);
}

SCHED_INTERN void
sched_semaphore_close(struct sched_semaphore *s)
{
    semaphore_destroy(mach_task_self(), s->sem);
}

SCHED_INTERN void
sched_semaphore_wait(struct sched_semaphore *s)
{
    semaphore_wait(s->sem);
}

SCHED_INTERN void
sched_semaphore_signal(struct sched_semaphore *s, int cnt)
{
    while (cnt-- > 0)
        semaphore_signal(s->sem);
}

#else /* POSIX */

#include <semaphore.h>

struct sched_semaphore {
    sem_t sem;
};

SCHED_INTERN void
sched_semaphore_create(struct sched_semaphore *s)
{
    int err = sem_init(&s->sem,0,0);
    SCHED_ASSERT(err == 0);
}

SCHED_INTERN void
sched_semaphore_close(struct sched_semaphore *s)
{
    sem_destroy(&s->sem);
}

SCHED_INTERN void
sched_semaphore_wait(struct sched_semaphore *s)
{
    int err = sem_wait(&s->sem);
    SCHED_ASSERT(err == 0);
}

SCHED_INTERN void
sched_semaphore_signal(struct sched_semaphore *s, int cnt)
{
    while (cnt-- > 0)
        sem_post(&s->sem);
}

#endif

#endif

/* ---------------------------------------------------------------
 *                          PIPE
 * ---------------------------------------------------------------*/
/*  PIPE
    Single writer, multiple reader thread safe pipe using (semi) lockless programming
    Readers can only read from the back of the pipe
    The single writer can write to the front of the pipe, and read from both
    ends (a writer can be a reader) for many of the principles used here,
    see http://msdn.microsoft.com/en-us/library/windows/desktop/ee418650(v=vs.85).aspx
    Note: using log2 sizes so we do not need to clamp (multi-operation)
    Note this is not true lockless as the use of flags as a form of lock state.
*/
/* IMPORTANT: Define this to control the maximum number of elements inside a
 * pipe as a log2 number. Should be smaller than 32 since it would otherwise
 * overflow the atomic integer type.*/
#ifndef SCHED_PIPE_SIZE_LOG2
#define SCHED_PIPE_SIZE_LOG2 8
#endif
#define SCHED_PIPE_SIZE (2 << SCHED_PIPE_SIZE_LOG2)
#define SCHED_PIPE_MASK (SCHED_PIPE_SIZE-1)
typedef int sched__check_pipe_size[(SCHED_PIPE_SIZE_LOG2 < 32) ? 1 : -1];

/* 32-Bit for compare-and-swap */
#define SCHED_PIPE_INVALID    0xFFFFFFFF
#define SCHED_PIPE_CAN_WRITE  0x00000000
#define SCHED_PIPE_CAN_READ   0x11111111

struct sched_subset_task {
    struct sched_task *task;
    struct sched_task_partition partition;
};

struct sched_pipe {
    struct sched_subset_task buffer[SCHED_PIPE_SIZE];
    /* read and write index allow fast access to the pipe
     but actual access is controlled by the access flags. */
    volatile sched_uint SCHED_BASE_ALIGN(4) write;
    volatile sched_uint SCHED_BASE_ALIGN(4) read_count;
    volatile sched_uint flags[SCHED_PIPE_SIZE];
    volatile sched_uint SCHED_BASE_ALIGN(4) read;
};

/* utility function, not intended for general use. Should only be used very prudenlty*/
#define sched_pipe_is_empty(p) (((p)->write - (p)->read_count) == 0)

SCHED_INTERN sched_int
sched_pipe_read_back(struct sched_pipe *pipe, struct sched_subset_task *dst)
{
    /* return false if we are unable to read. This is thread safe for both
     * multiple readers and the writer */
    sched_uint to_use;
    sched_uint previous;
    sched_uint actual_read;
    sched_uint read_count;

    SCHED_ASSERT(pipe);
    SCHED_ASSERT(dst);

    /* we get hold of the read index for consistency,
     * and do first pass starting at read count */
    read_count = pipe->read_count;
    to_use = read_count;
    while (1) {
        sched_uint write_index = pipe->write;
        sched_uint num_in_pipe = write_index - read_count;
        if (!num_in_pipe)
            return 0;

        /* move back to start */
        if (to_use >= write_index)
            to_use = pipe->read;

        /* power of two sizes ensures we can perform AND for a modulus */
        actual_read = to_use & SCHED_PIPE_MASK;
        /* multiple potential readers means we should check if the data is valid
         * using an atomic compare exchange */
        previous = sched_atomic_cmp_swp(&pipe->flags[actual_read], SCHED_PIPE_INVALID, SCHED_PIPE_CAN_READ);
        if (previous == SCHED_PIPE_CAN_READ)
            break;

        /* update known read count */
        read_count = pipe->read_count;
        ++to_use;
    }

    /* we update the read index using an atomic add, ws we've only read one piece
     * of data. This ensures consitency of the read index, and the above loop ensures
     * readers only read from unread data. */
    sched_atomic_add((volatile sched_int*)&pipe->read_count, 1);
    SCHED_BASE_MEMORY_BARRIER_ACQUIRE();

    /* now read data, ensuring we do so after above reads & CAS */
    *dst = pipe->buffer[actual_read];
    pipe->flags[actual_read] = SCHED_PIPE_CAN_WRITE;
    return 1;
}

SCHED_INTERN sched_int
sched_pipe_read_front(struct sched_pipe *pipe, struct sched_subset_task *dst)
{
    sched_uint prev;
    sched_uint actual_read = 0;
    sched_uint write_index;
    sched_uint front_read;

    write_index = pipe->write;
    front_read = write_index;

    /* Mutliple potential reads mean we should check if the data is valid,
     * using an atomic compare exchange - which acts as a form of lock */
    prev = SCHED_PIPE_INVALID;
    actual_read = 0;
    while (1) {
        /* power of two ensures we can use a simple cal without modulus */
        sched_uint read_count = pipe->read_count;
        sched_uint num_in_pipe = write_index - read_count;
        if (!num_in_pipe || !front_read) {
            pipe->read = read_count;
            return 0;
        }

        --front_read;
        actual_read = front_read & SCHED_PIPE_MASK;
        prev = sched_atomic_cmp_swp(&pipe->flags[actual_read], SCHED_PIPE_INVALID, SCHED_PIPE_CAN_READ);
        if (prev == SCHED_PIPE_CAN_READ) break;
        else if (pipe->read >= front_read) return 0;
    }

    /* now read data, ensuring we do so after above reads & CAS */
    *dst = pipe->buffer[actual_read];
    pipe->flags[actual_read] = SCHED_PIPE_CAN_WRITE;
    SCHED_BASE_MEMORY_BARRIER_RELEASE();

    /* 32-bit aligned stores are atomic, and writer owns the write index */
    --pipe->write;
    return 1;
}

SCHED_INTERN sched_int
sched_pipe_write(struct sched_pipe *pipe, const struct sched_subset_task *src)
{
    sched_uint actual_write;
    sched_uint write_index;
    SCHED_ASSERT(pipe);
    SCHED_ASSERT(src);

    /* The writer 'owns' the write index and readers can only reduce the amout of
     * data in the pipe. We get hold of both values for consistentcy and to
     * reduce false sharing impacting more than one access */
    write_index = pipe->write;

    /* power of two sizes ensures we can perform AND for a modulus*/
    actual_write = write_index & SCHED_PIPE_MASK;
    /* a read may still be reading this item, as there are multiple readers */
    if (pipe->flags[actual_write] != SCHED_PIPE_CAN_WRITE)
        return 0; /* still being read, so have caught up with tail */

    /* as we are the only writer we can update the data without atomics whilst
     * the write index has not been updated. */
    pipe->buffer[actual_write] = *src;
    pipe->flags[actual_write] = SCHED_PIPE_CAN_READ;

    /* we need to ensure the above occur prior to updating the write index,
     * otherwise another thread might read before it's finished */
    SCHED_BASE_MEMORY_BARRIER_RELEASE();
    /* 32-bit aligned stores are atomic, and writer owns the write index */
    ++write_index;
    pipe->write = write_index;
    return 1;
}

/* ---------------------------------------------------------------
 *                          SCHEDULER
 * ---------------------------------------------------------------*/
/* IMPORTANT: Define this to control the maximum number of iterations for a
 * thread to check for work until it is send into a sleeping state */
#ifndef SCHED_SPIN_COUNT_MAX
#define SCHED_SPIN_COUNT_MAX 100
#endif
#ifndef SCHED_SPIN_BACKOFF_MUL
#define SCHED_SPIN_BACKOFF_MUL 10
#endif
#ifndef SCHED_MAX_NUM_INITIAL_PARTITIONS
#define SCHED_MAX_NUM_INITIAL_PARTITIONS 8
#endif

struct sched_thread_args {
    sched_uint thread_num;
    struct scheduler *scheduler;
};
SCHED_GLOBAL const sched_size sched_pipe_align = SCHED_ALIGNOF(struct sched_pipe);
SCHED_GLOBAL const sched_size sched_arg_align = SCHED_ALIGNOF(struct sched_thread_args);
SCHED_GLOBAL const sched_size sched_thread_align = SCHED_ALIGNOF(sched_thread);
SCHED_GLOBAL const sched_size sched_semaphore_align = SCHED_ALIGNOF(struct sched_semaphore);
SCHED_GLOBAL SCHED_THREAD_LOCAL sched_uint gtl_thread_num = 0;

SCHED_INTERN struct sched_subset_task
sched_split_task(struct sched_subset_task *st, sched_uint range_to_split)
{
    struct sched_subset_task res = *st;
    sched_uint range_left = st->partition.end - st->partition.start;
    if (range_to_split > range_left)
        range_to_split = range_left;
    res.partition.end = st->partition.start + range_to_split;
    st->partition.start = res.partition.end;
    return res;
}
SCHED_INTERN void
sched_wake_threads(struct scheduler *s)
{
    sched_semaphore_signal(s->new_task_semaphore, s->thread_waiting);
}
SCHED_INTERN void
sched_split_add_task(struct scheduler *s, sched_uint thread_num,
    struct sched_subset_task *st, sched_uint range_to_split, sched_int off)
{
    sched_int cnt = 0;
    while (st->partition.start != st->partition.end) {
        struct sched_subset_task t = sched_split_task(st, range_to_split);
        ++cnt;
        if (!sched_pipe_write(&s->pipes[gtl_thread_num], &t)) {
            if (cnt > 1) sched_wake_threads(s);
            if (t.task->range_to_run < range_to_split) {
                t.partition.end = t.partition.start + t.task->range_to_run;
                st->partition.start = t.partition.end;
            }
            t.task->exec(t.task->userdata, s, t.partition, thread_num);
            --cnt;
        }
    }
    sched_atomic_add(&st->task->run_count, cnt + off);
    sched_wake_threads(s);
}

SCHED_INTERN sched_int
sched_try_running_task(struct scheduler *s, sched_uint thread_num, sched_uint *pipe_hint)
{
    /* check for tasks */
    struct sched_subset_task subtask;
    sched_int have_task = sched_pipe_read_front(&s->pipes[thread_num], &subtask);
    sched_uint thread_to_check = *pipe_hint;
    sched_uint check_count = 0;

    while (!have_task && check_count < s->threads_num) {
        thread_to_check = (*pipe_hint + check_count) % s->threads_num;
        if (thread_to_check != thread_num)
            have_task = sched_pipe_read_back(&s->pipes[thread_to_check], &subtask);
        ++check_count;
    }
    if (have_task) {
        sched_uint part_size = subtask.partition.end - subtask.partition.start;
        /* update hint, will preserve value unless actually got task from another thread */
        *pipe_hint = thread_to_check;
        if (subtask.task->range_to_run < part_size) {
            struct sched_subset_task t = sched_split_task(&subtask, subtask.task->range_to_run);
            sched_split_add_task(s, gtl_thread_num, &subtask, subtask.task->range_to_run, 0);
            subtask.task->exec(t.task->userdata, s, t.partition, thread_num);
            sched_atomic_add(&t.task->run_count, -1);
        } else {
            /* the task has already been divided up by scheduler_add, so just run */
            subtask.task->exec(subtask.task->userdata, s, subtask.partition, thread_num);
            sched_atomic_add(&subtask.task->run_count, -1);
        }
    } return have_task;
}

SCHED_INTERN void
sched_call(sched_profiler_callback_f fn, void *usr, sched_uint threadid)
{
    if (fn) fn(usr, threadid);
}

SCHED_INTERN void
scheduler_wait_for_work(struct scheduler *s, sched_uint thread_num)
{
    sched_uint i = 0;
    sched_int have_tasks = 0;
    sched_atomic_add(&s->thread_waiting, 1);
    for (i = 0; i < s->threads_num; ++i) {
        if (!sched_pipe_is_empty(&s->pipes[i])) {
            have_tasks = 1;
            break;
        }
    }
    if (!have_tasks) {
        sched_call(s->profiling.wait_start, s->profiling.userdata, thread_num);
        sched_semaphore_wait(s->new_task_semaphore);
        sched_call(s->profiling.wait_stop, s->profiling.userdata, thread_num);
    }
    sched_atomic_add(&s->thread_waiting, -1);
}

#if defined _WIN32
  #if defined _M_IX86 || defined _M_X64
    #pragma intrinsic(_mm_pause)
    SCHED_INTERN void sched_pause(void) {_mm_pause();}
  #endif
#elif defined __i386__ || defined __x86_64__
    SCHED_INTERN void sched_pause(void) {__asm__ __volatile__("pause;");}
#else
    SCHED_INTERN void sched_pause(void) {;} /* may have NOP or yield euiv */
#endif

SCHED_INTERN SCHED_THREAD_FUNC_DECL
sched_tasking_thread_f(void *pArgs)
{
    sched_uint spin_count = 0, hint_pipe;
    struct sched_thread_args args = *(struct sched_thread_args*)pArgs;
    sched_uint thread_num = args.thread_num;
    struct scheduler *s = args.scheduler;
    gtl_thread_num = args.thread_num;

    sched_atomic_add(&s->thread_running, 1);
    sched_call(s->profiling.thread_start, s->profiling.userdata, thread_num);
    hint_pipe = thread_num + 1;
    while (s->running) {
        if (!sched_try_running_task(s, thread_num, &hint_pipe)) {
            ++spin_count;
            if (spin_count > SCHED_SPIN_COUNT_MAX) {
                scheduler_wait_for_work(s, thread_num);
                spin_count = 0;
            } else {
                sched_uint backoff = spin_count * SCHED_SPIN_BACKOFF_MUL;
                while (backoff) {
                    sched_pause();
                    --backoff;
                }
            }
        } else spin_count = 0;
    }
    sched_atomic_add(&s->thread_running, -1);
    sched_call(s->profiling.thread_stop, s->profiling.userdata, thread_num);
    return 0;
}

SCHED_API void
scheduler_init(struct scheduler *s, sched_size *memory,
    sched_int thread_count, const struct sched_profiling *prof)
{
    SCHED_ASSERT(s);
    SCHED_ASSERT(memory);

    sched_zero_struct(*s);
    s->threads_num = (thread_count == SCHED_DEFAULT)?
        sched_num_hw_threads() : (sched_uint)thread_count;

    /* ensure we have sufficent tasks to equally fill either all threads including
     * main or just the threads we've launched, this is outisde the first init
     * as we want to be able to runtime change it */
    if (s->threads_num > 1) {
        s->partitions_num = s->threads_num * (s->threads_num-1);
        s->partitions_init_num = s->threads_num-1;
        if (s->partitions_init_num > SCHED_MAX_NUM_INITIAL_PARTITIONS)
            s->partitions_init_num = SCHED_MAX_NUM_INITIAL_PARTITIONS;
    } else {
        s->partitions_num = 1;
        s->partitions_init_num = 1;
    }
    if (prof) s->profiling = *prof;

    /* calculate needed memory */
    SCHED_ASSERT(s->threads_num > 0);
    *memory = 0;
    *memory += sizeof(struct sched_pipe) * s->threads_num;
    *memory += sizeof(struct sched_thread_args) * s->threads_num;
    *memory += sizeof(sched_thread) * s->threads_num;
    *memory += sizeof(struct sched_semaphore);
    *memory += sched_pipe_align + sched_arg_align;
    *memory += sched_thread_align + sched_semaphore_align;
    s->memory = *memory;
}

SCHED_API void
scheduler_start(struct scheduler *s, void *memory)
{
    sched_uint i = 0;
    SCHED_ASSERT(s);
    SCHED_ASSERT(memory);
    if (s->have_threads) return;
    scheduler_stop(s, 0);

    /* setup scheduler memory */
    sched_zero_size(memory, s->memory);
    s->pipes = (struct sched_pipe*)SCHED_ALIGN_PTR(memory, sched_pipe_align);
    s->threads = SCHED_ALIGN_PTR(s->pipes + s->threads_num, sched_thread_align);
    s->args = (struct sched_thread_args*) SCHED_ALIGN_PTR(
        SCHED_PTR_ADD(void, s->threads, sizeof(sched_thread) * s->threads_num), sched_arg_align);
    s->new_task_semaphore = (struct sched_semaphore*)SCHED_ALIGN_PTR(s->args + s->threads_num, sched_semaphore_align);
    sched_semaphore_create(s->new_task_semaphore);

    /* Create one less thread than thread_num as the main thread counts as one */
    s->args[0].thread_num = 0;
    s->args[0].scheduler = s;
#if  defined(_WIN32) && !(defined(__MINGW32__) || defined(__MINGW64__))
    ((sched_thread*)(s->threads)) [0] = 0;
#endif
    s->thread_running = 1;
    s->thread_waiting = 0;
    s->running = 1;

    /* start hardware threads */
    for (i = 1; i < s->threads_num; ++i) {
        s->args[i].thread_num = i;
        s->args[i].scheduler = s;
        sched_thread_create(&((sched_thread*)(s->threads))[i],
            sched_tasking_thread_f, &s->args[i]);
    } s->have_threads = 1;
}

SCHED_API void
scheduler_add(struct scheduler *s, struct sched_task *task,
    sched_run func, void *pArg, sched_uint size, sched_uint min_range)
{
    sched_uint range_to_split = 0;
    struct sched_subset_task subtask;
    SCHED_ASSERT(s);
    SCHED_ASSERT(task);
    SCHED_ASSERT(func);

    task->userdata = pArg;
    task->exec = func;
    task->size = size > 0 ? size: 1;
    task->run_count = -1;
    task->min_range = min_range > 0 ? min_range: 1;
    task->range_to_run = task->size / s->partitions_num;
    if (task->range_to_run < task->min_range)
        task->range_to_run = task->min_range;

    range_to_split = task->size / s->partitions_init_num;
    if (range_to_split < task->min_range)
        range_to_split = task->min_range;

    subtask.task = task;
    subtask.partition.start = 0;
    subtask.partition.end = task->size;
    sched_split_add_task(s, gtl_thread_num, &subtask, range_to_split, 1);
}

SCHED_API void
scheduler_join(struct scheduler *s, struct sched_task *task)
{
    sched_uint pipe_to_check = gtl_thread_num+1;
    SCHED_ASSERT(s);
    if (task) {
        while (task->run_count)
            sched_try_running_task(s, gtl_thread_num, &pipe_to_check);
    } else sched_try_running_task(s, gtl_thread_num, &pipe_to_check);
}

SCHED_API void
scheduler_wait(struct scheduler *s)
{
    sched_int have_task = 1;
    sched_uint pipe_hint = gtl_thread_num+1;
    while (have_task || s->thread_waiting < (s->thread_running-1)) {
        sched_uint i = 0;
        sched_try_running_task(s, gtl_thread_num, &pipe_hint);
        have_task = 0;
        for (i = 0; i < s->threads_num; ++i) {
            if (!sched_pipe_is_empty(&s->pipes[i])) {
                have_task = 1;
                break;
            }
        }
    }
}

SCHED_API void
scheduler_stop(struct scheduler *s, int doWait)
{
    sched_uint i = 0;
    SCHED_ASSERT(s);
    if (!s->have_threads)
        return;

    /* wait for threads to quit and terminate them */
    s->running = 0;
    scheduler_wait(s);
    while (doWait && s->thread_running > 1) {
        /* keep firing event to ensure all threads pick up state of running*/
        sched_semaphore_signal(s->new_task_semaphore, s->thread_running);
    }
    for (i = 1; i < s->threads_num; ++i)
        sched_thread_term(((sched_thread*)(s->threads))[i]);

    sched_semaphore_close(s->new_task_semaphore);
    s->new_task_semaphore = 0;
    s->thread_running = 0;
    s->thread_waiting = 0;
    s->have_threads = 0;
    s->threads = 0;
    s->pipes = 0;
    s->new_task_semaphore = 0;
    s->args = 0;
}

#endif /* SCHED_IMPLEMENTATION */


#ifdef SCHED_DEMO
#include <stdio.h>
static void parallel_task(void *pArg, struct scheduler *s, struct sched_task_partition p, sched_uint thread_num) {
    /* Do something here, cann issue additional tasks into the scheduler */
    puts(".");
}
int main(int argc, const char **argv) 
{
    void *memory;
    sched_size needed_memory;

    struct scheduler sched;
    scheduler_init(&sched, &needed_memory, SCHED_DEFAULT, 0);
    memory = calloc(needed_memory, 1);
    scheduler_start(&sched, memory);
    {
        struct sched_task task;
        scheduler_add(&sched, &task, parallel_task, NULL, 1, 1);
        scheduler_join(&sched, &task);
    }
    scheduler_stop(&sched, 1);
    free(memory);
}
#endif
