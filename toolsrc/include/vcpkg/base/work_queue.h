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
        template<class Action, class ThreadLocalData>
        auto call_moved_action(Action& action,
                               const WorkQueue<Action, ThreadLocalData>& work_queue,
                               ThreadLocalData& tld) -> decltype(static_cast<void>(std::move(action)(tld, work_queue)))
        {
            std::move(action)(tld, work_queue);
        }

        template<class Action, class ThreadLocalData>
        auto call_moved_action(Action& action, const WorkQueue<Action, ThreadLocalData>&, ThreadLocalData& tld)
            -> decltype(static_cast<void>(std::move(action)(tld)))
        {
            std::move(action)(tld);
        }
    }

    template<class Action, class ThreadLocalData>
    struct WorkQueue
    {
        template<class F>
        WorkQueue(std::uint16_t num_threads, LineInfo li, const F& tld_init) noexcept
        {
            m_line_info = li;

            m_unjoined_workers = num_threads;
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

            for (;;)
            {
                auto lck = std::unique_lock<std::mutex>(m_mutex);
                if (!m_unjoined_workers)
                    break;

                else if (!m_running_workers)
                {
                    lck.unlock();
                    m_cv.notify_all();
                }
            }

            // all threads have returned -- now, it's time to join them
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

        template<class Rng>
        void enqueue_all_actions_by_move(Rng&& rng) const
        {
            {
                using std::begin;
                using std::end;

                auto lck = std::unique_lock<std::mutex>(m_mutex);

                const auto first = begin(rng);
                const auto last = end(rng);

                m_actions.reserve(m_actions.size() + (last - first));

                std::move(first, last, std::back_inserter(rng));

                if (m_state == State::BeforeRun) return;
            }

            m_cv.notify_all();
        }

        template<class Rng>
        void enqueue_all_actions(Rng&& rng) const
        {
            {
                using std::begin;
                using std::end;

                auto lck = std::unique_lock<std::mutex>(m_mutex);

                const auto first = begin(rng);
                const auto last = end(rng);

                m_actions.reserve(m_actions.size() + (last - first));

                std::copy(first, last, std::back_inserter(rng));

                if (m_state == State::BeforeRun) return;
            }

            m_cv.notify_all();
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

                for (;;)
                {
                    const auto state = work_queue->m_state;

                    if (is_terminated(state))
                    {
                        break;
                    }

                    if (work_queue->m_actions.empty())
                    {
                        if (state == State::Running || work_queue->m_running_workers > 1)
                        {
                            --work_queue->m_running_workers;
                            work_queue->m_cv.wait(lck);
                            ++work_queue->m_running_workers;
                            continue;
                        }

                        // the queue isn't running, and we are the only worker
                        // no more work!
                        break;
                    }

                    Action action = std::move(work_queue->m_actions.back());
                    work_queue->m_actions.pop_back();

                    lck.unlock();
                    detail::call_moved_action(action, *work_queue, tld);
                    lck.lock();
                }

                --work_queue->m_unjoined_workers;
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
        mutable std::uint16_t m_running_workers = 0;
        mutable std::uint16_t m_unjoined_workers = 0; // num_threads
        mutable std::vector<Action> m_actions{};
        mutable std::condition_variable m_cv{};

        std::vector<std::thread> m_threads{};
        LineInfo m_line_info;
    };
}
