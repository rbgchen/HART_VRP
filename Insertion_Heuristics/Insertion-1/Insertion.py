"""
Insertion heuristic for the first way to calculate c2, minimizing push forward and wait times.
"""
from csv_to_list import csv_to_array
from results_to_csv import results_to_csv

# Path constants
a_path = "../data/a.csv"
b_path = "../data/b.csv"
s_path = "../data/s.csv"
t_path = "../data/t.csv"
d_path = "../data/d.csv"

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
HOME = 0
P_PLUS = set(range(1, int((len(a)-2)/2) + 1))
P_MINUS = set(range(max(P_PLUS) + 1, len(a) - 1))
DEPOT = max(P_MINUS) + 1
P = P_PLUS | P_MINUS
N = {HOME} | P | {DEPOT}
INITIAL_PATH = [[0 if (i, j) != (HOME, DEPOT) else 1 for j in N] for i in N]
INITIAL_T = [-float('inf') if i != HOME and i != DEPOT else 0 for i in N]


def print_path(path):
    """
    Prints a path with each i in a different row
    :param path: The path to be printed
    """
    for i in range(len(path)):
        print(path[i])  # Prints each row individually
    print()  # Prints a new line


def print_timetable(timetable):
    """
    Prints a timetable with start times for each node
    :param timetable: The timetable to be printed
    """
    print('u\tTᵤ\twait time')
    for i in timetable:
        print(f'{i}\t{timetable[i][0]}' + (3 - len(str(timetable[i][0])) + 4) * ' ' + f'{timetable[i][1]}')
        # Prints the node, followed by a tab, and the time of that node
    print()  # Prints a new line


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
    return [timetable[i] for i in range(len(timetable))]


def eval_c_2(path, timetable, i, u, j):
    """
    Calculates the c_2, along with the new path and timetable given
    a current timetable, path, source, insertion, and destination
    :param path: The current path being used
    :param timetable: The current timetable being used
    :param i: The source node
    :param u: The node to be inserted
    :param j: The destination node
    :return: The c2, new path, and timetable after insertion of u. Will return -inf, None, None if invalid insertion.
    """
    new_path = copy_path(path)
    new_T = copy_timetable(timetable)
    new_T[u] = max(a[u], timetable[i] + s[i] + t[i][u])
    new_T[j] = max(a[j], new_T[u] + s[u] + t[u][j])
    c_12 = new_T[j] - timetable[j]

    for node in range(len(new_T)):
        # Pushes forward the times of each node after insertion and checks if it exceeds latest time.

        if timetable[node] >= timetable[j]:
            new_T[node] = timetable[node] + c_12

        if new_T[node] > b[node]:
            return float('-inf'), None, None

    c_11 = d[i][u] + d[u][j] - MU * d[i][j]
    c_1 = ALPHA_1 * c_11 + ALPHA_2 * c_12
    c_2 = LAMBDA * d[0][u] - c_1

    # Inserts new node
    new_path[i][j] = 0
    new_path[i][u] = 1
    new_path[u][j] = 1

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

        for i in N - {u, DEPOT}:
            for j in N - {u, HOME}:
                if path[i][j] == 1:
                    c_2_p_temp, path_p_temp, T_p_temp = eval_c_2(path, timetable, i, u, j)

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
    N_d = N - (N - (P_PLUS | P_MINUS))  # Ensures that the dropoff comes AFTER the pickup
    for i in N_d | {u}:
        for j in N_d | {DEPOT}:
            if path[i][j] == 1:
                c_2_d_temp, path_d_temp, T_d_temp = eval_c_2(path, timetable, i, u_d, j)

                if c_2_d_temp > c_2_d:
                    c_2_d = c_2_d_temp
                    path_d = path_d_temp
                    T_d = T_d_temp

    return c_2_d, path_d, T_d


def clean_timetable(timetable):
    """
    Cleans the timetable by sorting it, packing it into a dictionary, and tightening the schedule.
    :param timetable: The original timetable.
    :return: The cleaned timetable.
    """
    new_timetable = {}
    previous_node = None
    wait_time = 0
    for i in range(len(timetable)):
        if timetable[i] != float('-inf'):

            new_timetable[i] = [timetable[i]]

            if i != 0:
                wait_time = a[i] - (new_timetable[previous_node][0] + s[previous_node] + t[previous_node][i])

                if wait_time < 0:  # Accounts for negative wait times
                    wait_time = 0.0

            new_timetable[i].append(wait_time)
            previous_node = i
    key_one = min(new_timetable, key=new_timetable.get)  # Grabs the second smallest time in the table
    new_timetable[0] = [timetable[key_one] - t[0][key_one], 0.0]
    new_timetable = dict(sorted(new_timetable.items(), key=lambda item: item[1]))
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

    for i in range(len(final_times)):
        final_times[i] = clean_timetable(final_times[i])

    results_to_csv(N, final_paths, final_times)
    print('Results have been written to results.csv.')


if __name__ == '__main__':
    insertion()
