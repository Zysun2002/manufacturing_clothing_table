import pandas as pd
import os
import itertools

A = [[40, 55],[50,70], [60, 85], [70, 100], [80, 115], [90, 130], [100, 145]]
B = [150, 300, 450, 600, 750, 900, 1050]
C = [120, 250, 550]
D = [6, 18]
E = [0.00005, 0.0005, 0.001, 0.0015, 0.002, 0.0025]
F = [0.8, 1]
G = [0.0003, 0.0006, 0.0009, 0.0012]
H = [100, 250, 400]
I = [1000, 2000]
J = [0.03, 0.06, 0.09]

# Generate (A, B) pairs
# Logic: Each group in A corresponds to one value in B.
# We expand the group in A and pair each element with the corresponding B value.
ab_pairs = []
if len(A) != len(B):
    print(f"Error: Length of A ({len(A)}) and B ({len(B)}) do not match.")
    exit()

for a_group, b_val in zip(A, B):
    for a_val in a_group:
        ab_pairs.append((a_val, b_val))

print(f"Generated {len(ab_pairs)} (A, B) pairs.")
# Example: [(40, 150), (50, 150), (50, 300), (70, 300), ...]

# Other variables to combine
other_vars = [C, D, E, F, G, H, I, J]

# Generate combinations of other variables
# itertools.product returns a generator, convert to list if needed or iterate directly
# To avoid memory issues if the list is huge, we can iterate.
# Number of combinations: 
# len(ab_pairs) * len(C) * ... * len(J)
# 14 * 3 * 2 * 6 * 2 * 4 * 3 * 2 * 3 = 14 * 10368 = 145,152 rows. This is manageable.

rows = []
for other_combo in itertools.product(*other_vars):
    # other_combo is (c, d, e, f, g, h, i, j)
    for a, b in ab_pairs:
        # Construct the full row
        # Order: A, B, C, D, E, F, G, H, I, J
        row = [a, b] + list(other_combo)
        rows.append(row)

# Define column names
column_names = [
    '环境温度(℃)', 
    '辐射热源温度(℃)', 
    '人体代谢率', 
    '服装整体湿阻/织物湿阻(m²·Pa/W)', 
    '空气层厚度(m)', 
    '外层发射率', 
    '外层厚度(m)', 
    '外层密度(Kg/m3)', 
    '外层比热容（J/kg·K）', 
    '外层导热系数(W/（m·K）)'
]

# Create DataFrame
df = pd.DataFrame(rows, columns=column_names)

# Save to Excel
script_dir = os.path.dirname(os.path.abspath(__file__))
output_path = os.path.join(script_dir, 'giant_table.xlsx')

print(f"Generating Excel file with {len(df)} rows...")
df.to_excel(output_path, index=False)
print(f"Done. Saved to {output_path}")

