#pragma once

#include <unordered_map>
#include <unordered_set>

#include <vcpkg/base/checks.h>

namespace vcpkg::Graphs
{
    enum class ExplorationStatus
    {
        // We have not visited this vertex
        NOT_EXPLORED,

        // We have visited this vertex but haven't visited all vertices in its subtree
        PARTIALLY_EXPLORED,

        // We have visited this vertex and all vertices in its subtree
        FULLY_EXPLORED
    };

    template<class V, class U>
    struct AdjacencyProvider
    {
        virtual std::vector<V> adjacency_list(const U& vertex) const = 0;

        virtual U load_vertex_data(const V& vertex) const = 0;
    };

    template<class V, class U>
    static void topological_sort_internal(const V& vertex,
                                          const AdjacencyProvider<V, U>& f,
                                          std::unordered_map<V, ExplorationStatus>& exploration_status,
                                          std::vector<U>& sorted)
    {
        ExplorationStatus& status = exploration_status[vertex];
        switch (status)
        {
            case ExplorationStatus::FULLY_EXPLORED: return;
            case ExplorationStatus::PARTIALLY_EXPLORED: Checks::exit_with_message(VCPKG_LINE_INFO, "cycle in graph");
            case ExplorationStatus::NOT_EXPLORED:
            {
                status = ExplorationStatus::PARTIALLY_EXPLORED;
                U vertex_data = f.load_vertex_data(vertex);
                for (const V& neighbour : f.adjacency_list(vertex_data))
                    topological_sort_internal(neighbour, f, exploration_status, sorted);

                sorted.push_back(std::move(vertex_data));
                status = ExplorationStatus::FULLY_EXPLORED;
                return;
            }
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    template<class V, class U>
    std::vector<U> topological_sort(const std::vector<V>& starting_vertices, const AdjacencyProvider<V, U>& f)
    {
        std::vector<U> sorted;
        std::unordered_map<V, ExplorationStatus> exploration_status;

        for (auto& vertex : starting_vertices)
        {
            topological_sort_internal(vertex, f, exploration_status, sorted);
        }

        return sorted;
    }

    template<class V>
    struct GraphAdjacencyProvider final : AdjacencyProvider<V, V>
    {
        const std::unordered_map<V, std::unordered_set<V>>& vertices;

        GraphAdjacencyProvider(const std::unordered_map<V, std::unordered_set<V>>& vertices) : vertices(vertices) {}

        std::vector<V> adjacency_list(const V& vertex) const override
        {
            const std::unordered_set<V>& as_set = this->vertices.at(vertex);
            return std::vector<V>(as_set.cbegin(), as_set.cend()); // TODO: Avoid redundant copy
        }

        V load_vertex_data(const V& vertex) const override { return vertex; }
    };

    template<class V>
    struct Graph
    {
    public:
        void add_vertex(V v) { this->vertices[v]; }

        // TODO: Change with iterators
        void add_vertices(const std::vector<V>& vs)
        {
            for (const V& v : vs)
            {
                this->vertices[v];
            }
        }

        void add_edge(V u, V v)
        {
            this->vertices[v];
            this->vertices[u].insert(v);
        }

        std::vector<V> topological_sort() const
        {
            GraphAdjacencyProvider<V> adjacency_provider{this->vertices};
            std::unordered_map<V, int> indegrees = count_indegrees();

            std::vector<V> sorted;
            sorted.reserve(indegrees.size());

            std::unordered_map<V, ExplorationStatus> exploration_status;
            exploration_status.reserve(indegrees.size());

            for (auto& pair : indegrees)
            {
                if (pair.second == 0) // Starting from vertices with indegree == 0. Not required.
                {
                    V vertex = pair.first;
                    topological_sort_internal(vertex, adjacency_provider, exploration_status, sorted);
                }
            }

            return sorted;
        }

        std::unordered_map<V, int> count_indegrees() const
        {
            std::unordered_map<V, int> indegrees;

            for (auto& pair : this->vertices)
            {
                indegrees[pair.first];
                for (V neighbour : pair.second)
                {
                    ++indegrees[neighbour];
                }
            }

            return indegrees;
        }

        const std::unordered_map<V, std::unordered_set<V>>& adjacency_list() const { return this->vertices; }
        std::vector<V> vertex_list() const
        {
            // why no &? it returns 0
            std::vector<V> vertex_list;
            for (const auto& vertex : this->vertices)
            {
                vertex_list.emplace_back(vertex.first);
            }
            return vertex_list;
        }

    private:
        std::unordered_map<V, std::unordered_set<V>> vertices;
    };
}
