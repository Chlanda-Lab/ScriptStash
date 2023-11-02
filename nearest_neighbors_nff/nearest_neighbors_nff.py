#!/usr/bin/env python3

# Very simple nearest-neighbor distance calculation from points in a NFF file.
# Only calculates nearest-neighbor distances between points in the same contour.
# Author: Moritz Wachsmuth-Melm, 2023

import sys
from os.path import basename
import numpy as np
import pandas as pd
from scipy.spatial.distance import euclidean

def parse_coords(line: str):
    return [float(field) for field in line.split()]

def read_file(path: str):
    contours = list()
    with open(path) as lines:
        for line in lines:
            line = line.strip()
            if line.startswith('p'):
                n_points = int(line.split()[1])
                df = pd.DataFrame.from_records(
                    [parse_coords(next(lines))
                        for _
                        in range(n_points)],
                    columns=['x', 'y', 'z'])
                df['contour'] = len(contours)
                contours.append(df)
    return pd.concat(contours, ignore_index=True)

def nearest_neighbor(dataframe):
    coords = dataframe[['x', 'y', 'z']]
    def min_distance(coord):
        distances = coords.agg(lambda neighbor: euclidean(coord, neighbor), axis=1)
        distances = distances[np.invert(np.isclose(distances, 0.0))]
        return distances.min()
    return coords.agg(min_distance, axis=1)


if __name__ == '__main__':
    for path in sys.argv[1:]:
        coords = read_file(path).drop_duplicates().reset_index()
        coords['nearest neighbor'] = coords.groupby('contour').apply(nearest_neighbor).reset_index()[0]
        coords.to_csv(f'{basename(path)}.csv')