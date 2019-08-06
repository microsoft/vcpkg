#pragma once

#include <condition_variable>
#include <memory>
#include <queue>

namespace vcpkg
{
    template<class Action, class ThreadLocalData>
    struct WorkQueue;

    namespace detail
    {
        // for SFINAE purposes, keep out of the class
        // also this sfinae is so weird because Backwards Compatibility with VS2015
        template<class Action,
                 class ThreadLocalData,
                 class = decltype(std::declval<Action>()(std::declval<ThreadLocalData&>(),
                                                         std::declval<const WorkQueue<Action, ThreadLocalData>&>()))>
        void call_moved_action(Action& action,
                               const WorkQueue<Action, ThreadLocalData>& work_queue,
                               ThreadLocalData& tld)
        {
            std::move(action)(tld, work_queue);
        }

        template<class Action,
                 class ThreadLocalData,
                 class = decltype(std::declval<Action>()(std::declval<ThreadLocalData&>())),
                 class = void>
        void call_moved_action(Action& action, const WorkQueue<Action, ThreadLocalData>&, ThreadLocalData& tld)
        {
            std::move(action)(tld);
        }
    }

    template<class Action, class ThreadLocalData>
    struct WorkQueue
    {
        template<class F>
        WorkQueue(LineInfo li, std::uint16_t num_threads, const F& tld_init) noexcept
        {
            m_line_info = li;

            set_unjoined_workers(num_threads);
            m_threads.reserve(num_threads);
            for (std::size_t i = 0; i < num_threads; ++i)
            {
                m_threads.push_back(std::thread(Worker{this, tld_init()}));
            }
        }

        WorkQueue(WorkQueue const&) = delete;
        WorkQueue(WorkQueue&&) = delete;

        ~WorkQueue()
        {
            auto lck = std::unique_lock<std::mutex>(m_mutex);
            if (!is_joined(m_state))
            {
                Checks::exit_with_message(m_line_info, "Failed to call join() on a WorkQueue that was destroyed");
            }
        }

        // should only be called once; anything else is an error
        void run(LineInfo li)
        {
            // this should _not_ be locked before `run()` is called; however, we
            // want to terminate if someone screws up, rather than cause UB
            auto lck = std::unique_lock<std::mutex>(m_mutex);

            if (m_state != State::BeforeRun)
            {
                Checks::exit_with_message(li, "Attempted to run() twice");
            }

            m_state = State::Running;
        }

        // runs all remaining tasks, and blocks on their finishing
        // if this is called in an existing task, _will block forever_
        // DO NOT DO THAT
        // thread-unsafe
        void join(LineInfo li)
        {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                if (is_joined(m_state))
                {
                    Checks::exit_with_message(li, "Attempted to call join() more than once");
                }
                else if (m_state == State::Terminated)
                {
                    m_state = State::TerminatedJoined;
                }
                else
                {
                    m_state = State::Joined;
                }
            }

            while (unjoined_workers())
            {
                if (!running_workers())
                {
                    m_cv.notify_one();
                }
            }

            // wait for all threads to join
            for (auto& thrd : m_threads)
            {
                thrd.join();
            }
        }

        // useful in the case of errors
        // doesn't stop any existing running tasks
        // returns immediately, so that one can call this in a task
        void terminate() const
        {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                if (is_joined(m_state))
                {
                    m_state = State::TerminatedJoined;
                }
                else
                {
                    m_state = State::Terminated;
                }
            }
            m_cv.notify_all();
        }

        void enqueue_action(Action a) const
        {
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                m_actions.push_back(std::move(a));

                if (m_state == State::BeforeRun) return;
            }
            m_cv.notify_one();
        }

    private:
        struct Worker
        {
            const WorkQueue* work_queue;
            ThreadLocalData tld;

            void operator()()
            {
                // unlocked when waiting, or when in the action
                // locked otherwise
                auto lck = std::unique_lock<std::mutex>(work_queue->m_mutex);

                work_queue->m_cv.wait(lck, [&] { return work_queue->m_state != State::BeforeRun; });

                work_queue->increment_running_workers();
                for (;;)
                {
                    const auto state = work_queue->m_state;

                    if (is_terminated(state))
                    {
                        break;
                    }

                    if (work_queue->m_actions.empty())
                    {
                        if (state == State::Running || work_queue->running_workers() > 1)
                        {
                            work_queue->decrement_running_workers();
                            work_queue->m_cv.wait(lck);
                            work_queue->increment_running_workers();
                            continue;
                        }

                        // the queue is joining, and we are the only worker running
                        // no more work!
                        break;
                    }

                    Action action = std::move(work_queue->m_actions.back());
                    work_queue->m_actions.pop_back();

                    lck.unlock();
                    work_queue->m_cv.notify_one();
                    detail::call_moved_action(action, *work_queue, tld);
                    lck.lock();
                }

                work_queue->decrement_running_workers();
                work_queue->decrement_unjoined_workers();
            }
        };

        enum class State : std::int16_t
        {
            // can only exist upon construction
            BeforeRun = -1,

            Running,
            Joined,
            Terminated,
            TerminatedJoined,
        };

        static bool is_terminated(State st) { return st == State::Terminated || st == State::TerminatedJoined; }

        static bool is_joined(State st) { return st == State::Joined || st == State::TerminatedJoined; }

        mutable std::mutex m_mutex{};
        // these are all under m_mutex
        mutable State m_state = State::BeforeRun;
        mutable std::vector<Action> m_actions{};
        mutable std::condition_variable m_cv{};

        mutable std::atomic<std::uint32_t> m_workers;
        // = unjoined_workers << 16 | running_workers

        void set_unjoined_workers(std::uint16_t threads) { m_workers = std::uint32_t(threads) << 16; }
        void decrement_unjoined_workers() const { m_workers -= 1 << 16; }

        std::uint16_t unjoined_workers() const { return std::uint16_t(m_workers >> 16); }

        void increment_running_workers() const { ++m_workers; }
        void decrement_running_workers() const { --m_workers; }
        std::uint16_t running_workers() const { return std::uint16_t(m_workers); }

        std::vector<std::thread> m_threads{};
        LineInfo m_line_info;
    };
}
