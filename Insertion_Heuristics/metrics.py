def get_route_metrics(d, t, s, depot, path, timetable):
    source = 0
    destination = 0
    total_distance = 0
    total_time = 0
    total_wait = 0
    temp_occupancy = 0
    average_occupancy = 0
    pick_cutoff = int(round((depot-1)/2))
    while source != depot:
        for i in path[source]:
            if i == 1:
                total_distance += d[source][destination]
                total_time += timetable[source][0] + s[source] + t[source][destination]
                total_wait += timetable[source][1]
                average_occupancy += temp_occupancy * (timetable[destination][0] - timetable[source][0])
                if destination > pick_cutoff:
                    temp_occupancy -= 1
                else:
                    temp_occupancy += 1
                source = destination
                destination = 0
                break
            destination += 1
    average_occupancy /= total_time
    return total_distance, total_time, total_wait, average_occupancy
