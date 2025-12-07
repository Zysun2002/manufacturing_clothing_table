import pandas as pd
import subprocess
import re
import os
from pathlib import Path
from tqdm import tqdm

import ipdb

# ==========================================
# USER CONFIGURATION
# ==========================================
MATLAB_EXE_PATH = r"E:\Ziyu\softwares\MATLAB\bin\matlab.exe"
EXCEL_FILE_PATH = r"E:\Ziyu\workspace\temp_workspace\generate_clothing_table\matlab\giant_table.csv"
# Directory where the MATLAB script will run from
WORKSPACE_DIR = r"E:\Ziyu\workspace\temp_workspace\generate_clothing_table\matlab"
TEST_LIMIT = None  # Debug: process only one row
# Disable frequent Excel writes to improve performance
SAVE_INTERVAL = 1  # Set to an integer (e.g., 100) to enable periodic saves
# ==========================================

def run_batch_simulation():
    matlab_exe = Path(MATLAB_EXE_PATH)
    excel_path = Path(EXCEL_FILE_PATH)
    workspace_dir = Path(WORKSPACE_DIR)
    
    print(f"Workspace Directory: {workspace_dir}")
    print(f"Reading input from: {excel_path}")
    
    if not excel_path.exists():
        print(f"Error: Input file not found at {excel_path}")
        return

    try:
        df = pd.read_excel(excel_path, engine='openpyxl')
    except Exception as e:
        print(f"Error reading Excel file: {e}")
        return

    # Drop legacy result columns (Chinese headers) if present
    legacy_cols = ['二度烧伤时间(s)', '三度烧伤时间(s)', '热应激时间(s)', '最终核心温度(℃)', '最终皮肤温度(℃)']
    df = df.drop(columns=legacy_cols, errors='ignore')

    # Determine rows to process: start from rows with no output data (all target cols NaN)
    target_cols = (
        ['t2brun', 't3brun', 'tstress'] +
        [f'Tcore{j:03d}' for j in range(1, 601)] +
        [f'Taverage{j:03d}' for j in range(1, 601)]
    )
    # Ensure columns exist for the mask; create temporarily if absent
    for c in target_cols:
        if c not in df.columns:
            df[c] = None

    empty_outputs_mask = df[target_cols].isna().all(axis=1)
    rows_to_process = df[empty_outputs_mask]

    if TEST_LIMIT is not None:
        subset = rows_to_process.head(TEST_LIMIT)
    else:
        subset = rows_to_process

    if len(subset) == 0:
        print("No rows with empty outputs; running debug on first row.")
        subset = df.head(1)

    print(f"Processing {len(subset)} rows (starting at first empty-output row)...")
    
    # Pre-create requested columns once to avoid fragmentation
    # (target_cols already defined above)
    missing_cols = [c for c in target_cols if c not in df.columns]
    if missing_cols:
        # Create a new DataFrame with missing columns initialized to None and concat once
        init_df = pd.DataFrame({c: [None] * len(df) for c in missing_cols})
        df = pd.concat([df.reset_index(drop=True), init_df], axis=1)

    for i, (index, row) in enumerate(tqdm(subset.iterrows(), total=len(subset), desc="Simulating")):
        # print(f"\nProcessing row {index + 1}...")

        try:
            # Helper to get value safely
            def get_val(col, default):
                return row[col] if col in row and pd.notna(row[col]) else default

            # Map columns to MATLAB variables
            params = {
                'Tamb': get_val('环境温度(℃)', 40),
                'Trad': get_val('辐射热源温度(℃)', 150),
                'met': get_val('人体代谢率', 120), # run.m handles the division by 58.2
                'Ret': get_val('服装整体湿阻/织物湿阻(m²·Pa/W)', 6),
                'Lair': get_val('空气层厚度(m)', 0.00005),
                'Eshell': get_val('外层发射率', 0.8),
                'Lshell': get_val('外层厚度(m)', 0.0003),
                'Dshell': get_val('外层密度(Kg/m3)', 100),
                'Sshell': get_val('外层比热容（J/kg·K）', 1000),
                'kshell': get_val('外层导热系数(W/（m·K）)', 0.03)
            }
            
            # Construct MATLAB command string
            # We change directory to workspace_dir inside MATLAB as well to be safe, 
            # although subprocess cwd should handle it.
            # Since the script is named 'run.m', it shadows the MATLAB 'run' function.
            # Calling 'run' directly will execute the script in the current directory.
            
            param_str = "; ".join([f"{k}={v}" for k, v in params.items()])
            # We use the filename without extension to run the script
            cmd_str = f"cd('{workspace_dir}'); {param_str}; run;"
            
            # print(f"Running MATLAB command: {cmd_str}")
            
            cmd = [matlab_exe, "-batch", cmd_str]
            
            # Run MATLAB
            # encoding='gbk' is often needed for Windows command line output in China region
            result = subprocess.run(cmd, capture_output=True, text=True, encoding='gbk', errors='ignore', cwd=workspace_dir)
            # print(f"MATLAB return code: {result.returncode}")

            if result.returncode != 0:
                print(f"MATLAB execution failed for row {index + 1}")
                # print(result.stdout)
                # print(result.stderr)
                continue

            # Parse output
            output = result.stdout
            # print("--- MATLAB stdout (first 500 chars) ---")
            print(output[:500])

            # Expect a single RESULTS line with 1203 comma-separated values
            extended_line = None
            for line in output.splitlines():
                if line.strip().startswith("RESULTS:"):
                    extended_line = line.strip()[len("RESULTS:"):].strip()
                    break

            if not extended_line:
                print(f"Could not find RESULTS line for row {index + 1}")
                continue
            
            parts = [p.strip() for p in extended_line.split(',')]
            # print(f"RESULTS parts count: {len(parts)}")
            try:
                values = [float(p) for p in parts]
            except ValueError:
                print(f"RESULTS line contains non-numeric values for row {index + 1}")
                continue

            if len(values) != 1203:
                print(f"RESULTS line has {len(values)} values (expected 1203) for row {index + 1}")
                continue

            # Vectorized assignment into pre-created columns with requested names/order
            df.loc[index, target_cols] = values
            # print(f"Wrote 1203 values to row {index}")

        except Exception as e:
            print(f"Error processing row {index + 1}: {e}")

        # Optional periodic saves if SAVE_INTERVAL is set
        if SAVE_INTERVAL and (i + 1) % SAVE_INTERVAL == 0:
            try:
                with pd.ExcelWriter(excel_path, engine='xlsxwriter') as writer:
                    df.to_excel(writer, index=False)
            except Exception as e:
                print(f"Error saving intermediate Excel file with xlsxwriter: {e}")
                try:
                    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
                        df.to_excel(writer, index=False)
                    print("Intermediate save successful using openpyxl.")
                except Exception as e2:
                    print(f"Fallback intermediate save failed: {e2}")

    # Save results back to the original file
    print(f"\nSaving updated data to {excel_path}...")
    try:
        # Use xlsxwriter for faster writes
        try:
            with pd.ExcelWriter(excel_path, engine='xlsxwriter') as writer:
                df.to_excel(writer, index=False)
            print("Save successful (xlsxwriter).")
        except Exception as e1:
            print(f"Save with xlsxwriter failed: {e1}. Falling back to openpyxl...")
            with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
                df.to_excel(writer, index=False)
            print("Save successful (openpyxl).")
    except Exception as e:
        print(f"Error saving Excel file: {e}")

if __name__ == "__main__":
    run_batch_simulation()
