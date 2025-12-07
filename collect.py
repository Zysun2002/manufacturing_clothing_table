import pandas as pd
import subprocess
import re
import os
from pathlib import Path
from tqdm import tqdm

# ==========================================
# USER CONFIGURATION
# ==========================================
MATLAB_EXE_PATH = r"E:\Ziyu\softwares\MATLAB\bin\matlab.exe"
EXCEL_FILE_PATH = r"E:\Ziyu\workspace\temp_workspace\generate_clothing_table\matlab\giant_table.xlsx"
# Directory where the MATLAB script will run from
WORKSPACE_DIR = r"E:\Ziyu\workspace\temp_workspace\generate_clothing_table\matlab"
TEST_LIMIT = None  # Set to None to process all rows
SAVE_INTERVAL = 1000
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
        df = pd.read_excel(excel_path)
    except Exception as e:
        print(f"Error reading Excel file: {e}")
        return

    # Ensure result columns exist in the DataFrame
    # Map internal variable names to Chinese column headers
    col_map_results = {
        't2burn': '二度烧伤时间(s)',
        't3burn': '三度烧伤时间(s)',
        'tstress': '热应激时间(s)',
        'Tcore': '最终核心温度(℃)',
        'Taverage': '最终皮肤温度(℃)'
    }
    
    for col in col_map_results.values():
        if col not in df.columns:
            df[col] = None

    # Determine rows to process
    # Filter for rows where the first result column is missing (NaN)
    target_col = col_map_results['t2burn']
    missing_data_mask = df[target_col].isna()
    
    rows_to_process = df[missing_data_mask]
    
    if TEST_LIMIT is not None:
        subset = rows_to_process.head(TEST_LIMIT)
    else:
        subset = rows_to_process
        
    print(f"Found {len(rows_to_process)} rows with missing data. Processing {len(subset)} rows...")
    
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
            
            if result.returncode != 0:
                print(f"MATLAB execution failed for row {index + 1}")
                # print(result.stdout)
                # print(result.stderr)
                continue

            # Parse output
            output = result.stdout
            # print(output) # Debugging

            # Regex to find 5 floating point numbers separated by commas
            # Matches numbers like 12.34, 0.00, -5.67
            match = re.search(r'(-?\d+\.\d+),(-?\d+\.\d+),(-?\d+\.\d+),(-?\d+\.\d+),(-?\d+\.\d+)', output)
            
            if match:
                # Update the original DataFrame directly using Chinese column names
                df.at[index, col_map_results['t2burn']] = float(match.group(1))
                df.at[index, col_map_results['t3burn']] = float(match.group(2))
                df.at[index, col_map_results['tstress']] = float(match.group(3))
                df.at[index, col_map_results['Tcore']] = float(match.group(4))
                df.at[index, col_map_results['Taverage']] = float(match.group(5))
                
                # print(f"Parsed and updated results for row {index + 1}")
            else:
                print(f"Could not parse results for row {index + 1}")
                # print(f"Output was: {output}")

        except Exception as e:
            print(f"Error processing row {index + 1}: {e}")

        # Save every 10 iterations
        if (i + 1) % SAVE_INTERVAL == 0:
            try:
                df.to_excel(excel_path, index=False)
            except Exception as e:
                print(f"Error saving intermediate Excel file: {e}")

    # Save results back to the original file
    print(f"\nSaving updated data to {excel_path}...")
    try:
        df.to_excel(excel_path, index=False)
        print("Save successful.")
    except Exception as e:
        print(f"Error saving Excel file: {e}")

if __name__ == "__main__":
    run_batch_simulation()
