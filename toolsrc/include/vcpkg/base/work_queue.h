#pragma once

#include <condition_variable>
#include <memory>
#include <vector>

namespace vcpkg
{
    template<class Action>
    struct WorkQueue
    {
        ~WorkQueue()
        {
            if (m_running_workers != 0)
                Checks::exit_with_message(VCPKG_LINE_INFO, "Destroying WorkQueue with outstanding workers");
        }

        // Should be called exactly once; anything else is an error
        template<class F>
        void run_and_join(LineInfo li, std::uint16_t num_threads, const F& tld_init)
        {
            // Short circuit if there are no actions
            if (m_actions.empty()) return;

            {
                // this should _not_ be locked before `run()` is called; however, we
                // want to terminate if someone screws up, rather than cause UB
                std::lock_guard<std::mutex> lck(m_mutex);

                if (m_state != State::BeforeRun)
                {
                    Checks::exit_with_message(li, "Attempted to run_and_join() twice");
                }

                m_state = State::Running;
                m_running_workers = num_threads;
                m_threads.reserve(num_threads);
                for (std::size_t i = 0; i < num_threads; ++i)
                {
                    m_threads.push_back(std::thread(Worker<decltype(tld_init())>{this, tld_init()}));
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
                std::lock_guard<std::mutex> lck(m_mutex);
                m_state = State::Terminated;
            }
            m_cv.notify_all();
        }

        void enqueue_action(Action a) const
        {
            {
                std::lock_guard<std::mutex> lck(m_mutex);
                m_actions.push_back(std::move(a));

                if (m_state == State::BeforeRun) return;
            }
            m_cv.notify_one();
        }

    private:
        template<class ThreadLocalData>
        struct Worker
        {
            const WorkQueue* work_queue;
            ThreadLocalData tld;

            void operator()()
            {
                // unlocked when waiting, or when in the action
                // locked otherwise
                std::unique_lock<std::mutex> lck(work_queue->m_mutex);
                for (;;)
                {
                    if (work_queue->m_state == State::Terminated)
                    {
                        --work_queue->m_running_workers;
                        return;
                    }

                    if (work_queue->m_actions.empty())
                    {
                        if (work_queue->m_running_workers == 1)
                        {
                            // we are the only worker running and no more work!
                            --work_queue->m_running_workers;
                            work_queue->m_cv.notify_all();
                            return;
                        }
                        else
                        {
                            --work_queue->m_running_workers;
                            work_queue->m_cv.wait(lck);
                            ++work_queue->m_running_workers;
                        }
                    }
                    else
                    {
                        Action action = std::move(work_queue->m_actions.back());
                        work_queue->m_actions.pop_back();

                        lck.unlock();
                        work_queue->m_cv.notify_one();
                        std::move(action)(tld, *work_queue);
                        lck.lock();
                    }
                }
            }
        };

        enum class State : std::int16_t
        {
            // can only exist upon construction
            BeforeRun,
            Running,
            Terminated,
        };

        mutable std::mutex m_mutex;
        // these are all under m_mutex
        mutable State m_state = State::BeforeRun;
        mutable std::vector<Action> m_actions;
        mutable std::condition_variable m_cv;

        mutable std::uint16_t m_running_workers = 0;

        std::vector<std::thread> m_threads;
    };
}
