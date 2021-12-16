"""
Insertion heuristic for the first way to calculate c2, minimizing push forward and wait times.
"""
from csv_to_list import csv_to_array
from results_to_csv import results_to_csv, record_metrics

# Path constants

hh_id = input('What is the id of the household that you want to use?')

a_path = f'data/{hh_id}_a.csv'
b_path = f'data/{hh_id}_b.csv'
s_path = f'data/{hh_id}_s.csv'
t_path = f'data/{hh_id}_TT.csv'
d_path = f'data/{hh_id}_TT.csv'


"""
a_path = "data/1002724_a.csv"
b_path = "data/1002724_b_tight_tw.csv"
s_path = "data/1002724_s_short.csv"
t_path = "data/1002724_TT.csv"
d_path = "data/1002724_TT.csv"
"""

"""
a_path = "data/1036350_a.csv"
b_path = "data/1036350_b.csv"
s_path = "data/1036350_s.csv"
t_path = "data/1036350_TT.csv"
d_path = "data/1036350_TT.csv"
"""

# Parameter Constants
MU = 1.0
ALPHA_1 = 0.50
ALPHA_2 = 0.50
LAMBDA = 1.0

# Network data
a = csv_to_array(a_path)
b = csv_to_array(b_path)
s = csv_to_array(s_path)
t = csv_to_array(t_path)
d = csv_to_array(d_path)
for i in range(len(t)):
    for j in range(len(t[i])):
        t[i][j] /= 60

HOME = 0
P_PLUS = set(range(1, int((len(a) - 2) / 2) + 1))
P_MINUS = set(range(max(P_PLUS) + 1, len(a) - 1))
DEPOT = max(P_MINUS) + 1
P = P_PLUS | P_MINUS
N = {HOME} | P | {DEPOT}
INITIAL_PATH = [[0 if (i, j) != (HOME, DEPOT) else 1 for j in N] for i in N]
INITIAL_T = [-float('inf') if i != HOME and i != DEPOT else 0 for i in N]


def copy_path(path):
    """
    Creates a copy of the path that does not link to the original since the .copy() method is malfunctioning.
    :param path: The path to be copied
    :return: The copy of the path
    """
    return [row[:] for row in path]


def copy_timetable(timetable):
    """
    Creates a copy of the timetable that won't link to the original since the .copy() method is malfunctioning.
    :param timetable: The timetable to be copied
    :return: The copied timetable
    """
    return [timetable[index] for index in range(len(timetable))]


def eval_c_2(path, timetable, source, u, destination):
    """
    Calculates the c_2, along with the new path and timetable given
    a current timetable, path, source, insertion, and destination
    :param path: The current path being used
    :param timetable: The current timetable being used
    :param source: The source node
    :param u: The node to be inserted
    :param destination: The destination node
    :return: The c2, new path, and timetable after insertion of u. Will return -inf, None, None if invalid insertion.
    """
    new_path = copy_path(path)
    new_T = copy_timetable(timetable)
    new_T[u] = max(a[u], timetable[source] + s[source] + t[source][u])
    new_T[destination] = max(a[destination], new_T[u] + s[u] + t[u][destination])
    c_12 = new_T[destination] - timetable[destination]

    for node in range(len(new_T)):
        # Pushes forward the times of each node after insertion and checks if it exceeds latest time.

        if timetable[node] > timetable[destination]:
            new_T[node] = timetable[node] + c_12

        if new_T[node] > b[node]:
            return float('-inf'), None, None

    c_11 = d[source][u] + d[u][destination] - MU * d[source][destination]
    c_1 = ALPHA_1 * c_11 + ALPHA_2 * c_12
    c_2 = LAMBDA * d[0][u] - c_1

    # Inserts new node
    new_path[source][destination] = 0
    new_path[source][u] = 1
    new_path[u][destination] = 1

    return c_2, new_path, new_T


def optimum_c_2(path, timetable):
    """
    Finds the optimum c2 in the current path and timetable
    :param path: The current path being used
    :param timetable: The current timetable being used
    :return: The optimum c2, path, and timetable with u to insert. Will return -inf, None, None if no valid insertions.
    """
    c_2_op = float('-inf')
    path_op = None
    T_op = None
    pick_remove = None
    drop_remove = None

    for u in P_PLUS:  # Iterates through each pickup node
        u_d = u + int(len(N) / 2) - 1

        for source in N - {u, DEPOT}:
            for destination in N - {u, HOME}:
                if path[source][destination] == 1:
                    c_2_p_temp, path_p_temp, T_p_temp = eval_c_2(path, timetable, source, u, destination)

                    if c_2_p_temp != float('-inf'):
                        c_2_d_temp, path_d_temp, T_d_temp = optimum_c_2_drop(path_p_temp, T_p_temp, u)

                        if (c_2_p_temp + c_2_d_temp) > c_2_op:  # Takes the maximum c_2
                            c_2_op = c_2_p_temp + c_2_d_temp
                            path_op = path_d_temp
                            T_op = T_d_temp
                            pick_remove = u
                            drop_remove = u_d

    if pick_remove is not None:
        P_PLUS.remove(pick_remove)
        P_MINUS.remove(drop_remove)

    return c_2_op, path_op, T_op


def optimum_c_2_drop(path, timetable, request):
    """
    Finds the optimum c2 of a dropoff node given the request node.
    :param path: The path currently being used
    :param timetable: The timetable currently being used
    :param request: The request to insert
    :return: The c2, path, and timetable with the dropoff node. Will return -inf, None, None if invalid.
    """
    u = request
    u_d = u + int(len(N) / 2) - 1
    c_2_d = float('-inf')
    path_d = None
    T_d = None
    source = 0
    destination = 0
    N_d = set({})
    while source != u:
        for link in path[source]:
            if link == 1:
                N_d |= {source}
                source = destination
                destination = 0
                break
            destination += 1
    N_d = N - N_d
    for source in N_d | {u}:
        for destination in (N_d | {DEPOT}) - {source}:
            if path[source][destination] == 1:
                c_2_d_temp, path_d_temp, T_d_temp = eval_c_2(path, timetable, source, u_d, destination)
                if c_2_d_temp > c_2_d:
                    c_2_d = c_2_d_temp
                    path_d = path_d_temp
                    T_d = T_d_temp

    return c_2_d, path_d, T_d


def clean_timetable(path):
    """
    Cleans the timetable by sorting it, packing it into a dictionary, and tightening the schedule.
    :param path: The final path
    :return: The cleaned timetable.
    """
    new_timetable = {0: [0, 0]}
    source = 0
    destination = 0
    while source != DEPOT:
        for link in path[source]:
            if link == 1:
                new_timetable[destination] = [
                    max(a[destination], new_timetable[source][0] + s[source] + t[source][destination]),
                    None]
                new_timetable[destination][1] = max(0, a[destination] - (new_timetable[source][0] + s[source]
                                                                         + t[source][destination]))
                source = destination
                destination = 0
                break
            destination += 1
    keys = list(new_timetable.keys())
    new_timetable[0][0] = new_timetable[keys[1]][0] - t[0][keys[1]]
    new_timetable[keys[1]][1] = 0
    return new_timetable


def insertion():
    """
    Main function that runs when the program is executed.
    Makes final paths based on c2, and handles any extra vehicles needed.
    Prints the final paths and timetables after tightening the timetable.
    """
    final_paths = []
    final_times = []

    path = copy_path(INITIAL_PATH)
    T = copy_timetable(INITIAL_T)

    updated_P = P_PLUS

    while len(updated_P) != 0:
        updated_P = P_PLUS  # Updates P_PLUS
        c2, path_temp, T_temp = optimum_c_2(path, T)  # Calculates best c2.

        if c2 == float('-inf'):  # If there is no optimum, use a new vehicle and create a new path.
            used_path = copy_path(path)
            used_T = copy_timetable(T)
            if used_path == INITIAL_PATH:
                break
            final_paths.append(used_path)
            final_times.append(used_T)
            path = copy_path(INITIAL_PATH)
            T = copy_timetable(INITIAL_T)

        else:
            path = copy_path(path_temp)
            T = copy_timetable(T_temp)
            updated_P = P_PLUS.union(P_MINUS)

    final_paths.append(path)
    final_times.append(T)

    for index in range(len(final_times)):
        final_times[index] = clean_timetable(final_paths[index])

    results_to_csv(N, final_paths, final_times, hh_id)
    record_metrics(d, t, s, DEPOT, final_paths, final_times, hh_id)
    print(f'Results have been written to {hh_id}_results.csv and {hh_id}_metrics.csv.')
    if len(updated_P) > 0:
        print(f'Uninserted requests: {updated_P}')


if __name__ == '__main__':
    insertion()
