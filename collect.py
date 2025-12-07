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
SAVE_INTERVAL = 1
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
    
    # Pre-create param_0001..param_1203 columns once to avoid fragmentation
    param_cols = [f"param_{j:04d}" for j in range(1, 1204)]
    missing_cols = [c for c in param_cols if c not in df.columns]
    if missing_cols:
        # Create a new DataFrame with missing columns initialized to None and concat once
        init_df = pd.DataFrame({c: [None] * len(df) for c in missing_cols})
        df = pd.concat([df.reset_index(drop=True), init_df], axis=1)

    for i, (index, row) in enumerate(tqdm(subset.iterrows(), total=len(subset), desc="Simulating")):
        # print(f"\nProcessing row {index + 1}...")
        import ipdb
        ipdb.set_trace()
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

            # First, try extended RESULTS line with 1203 CSV values
            extended_line = None
            for line in output.splitlines():
                if line.strip().startswith("RESULTS:"):
                    extended_line = line.strip()[len("RESULTS:"):].strip()
                    break

            parsed = False
            if extended_line:
                parts = [p.strip() for p in extended_line.split(',') if p.strip() != '']
                values = []
                for p in parts:
                    try:
                        values.append(float(p))
                    except ValueError:
                        p_norm = p.replace('D', 'E').replace('d', 'e')
                        try:
                            values.append(float(p_norm))
                        except ValueError:
                            values.append(None)
                if len(values) == 1203:
                    for j, val in enumerate(values, start=1):
                        df.at[index, f"param_{j:04d}"] = val
                    parsed = True

            if not parsed:
                # Fallback: parse MATLAB table (time, core, average) and summary echoes
                core_vals = []
                avg_vals = []
                table_started = False
                for line in output.splitlines():
                    l = line.strip()
                    if ('时间' in l) or ('Ê±¼ä' in l):
                        table_started = True
                        continue
                    if table_started:
                        m = re.match(r"^\s*([0-9]+)\s+([+-]?[0-9]*\.?[0-9]+)\s+([+-]?[0-9]*\.?[0-9]+)\s*$", l)
                        if m:
                            try:
                                core_vals.append(float(m.group(2)))
                                avg_vals.append(float(m.group(3)))
                            except ValueError:
                                pass
                        if len(core_vals) >= 600 and len(avg_vals) >= 600:
                            break

                # Extract t2burn/t3burn/tstress from variable echoes if present
                def extract_num_after(label):
                    # Handles forms like: t2burn =\n    4.6000 or t2burn = 4.6000
                    m = re.search(label + r"\s*=\s*([+-]?[0-9]*\.?[0-9]+)", output)
                    if m:
                        try:
                            return float(m.group(1))
                        except ValueError:
                            return None
                    return None

                t2 = extract_num_after('t2burn')
                t3 = extract_num_after('t3burn')
                ts = extract_num_after('tstress')

                # Assemble 1203: 3 summary + 600 core + 600 average
                if len(core_vals) or len(avg_vals):
                    # Pad/truncate to 600
                    def fit600(vals):
                        vals = list(vals)
                        if len(vals) < 600:
                            vals += [None] * (600 - len(vals))
                        else:
                            vals = vals[:600]
                        return vals
                    core600 = fit600(core_vals)
                    avg600 = fit600(avg_vals)

                    df.at[index, "param_0001"] = t2
                    df.at[index, "param_0002"] = t3
                    df.at[index, "param_0003"] = ts
                    for j, val in enumerate(core600, start=4):
                        df.at[index, f"param_{j:04d}"] = val
                    for j, val in enumerate(avg600, start=604):
                        df.at[index, f"param_{j:04d}"] = val
                    parsed = True

            if not parsed:
                print(f"Could not parse results for row {index + 1}")

        except Exception as e:
            print(f"Error processing row {index + 1}: {e}")

        # Save every 10 iterations
        if (i + 1) % SAVE_INTERVAL == 0:
            try:
                df.to_excel(excel_path, index=False, engine='openpyxl')
            except Exception as e:
                print(f"Error saving intermediate Excel file: {e}")

    # Save results back to the original file
    print(f"\nSaving updated data to {excel_path}...")
    try:
        df.to_excel(excel_path, index=False, engine='openpyxl')
        print("Save successful.")
    except Exception as e:
        print(f"Error saving Excel file: {e}")

if __name__ == "__main__":
    run_batch_simulation()
