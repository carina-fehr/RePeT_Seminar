import os
import re
import pandas as pd

LOG_DIR = "./logs"
OUTPUT_FILE = "results_combined.xlsx"

rows_list = [100, 1000, 10000, 100000, 500000, 1000000]
datasizes = [1000, 4000, 16000, 32000, 64000]

client = re.compile(r"client compute time: ([\d.]+)(ms|s)")
write_op = re.compile(r"average write operation time .*?: ([\d.]+)(ms|s)")
read_op = re.compile(r"average read operation time .*?: ([\d.]+)(ms|s)")

def convert_to_ms(value, unit): # Convert seconds to ms if needed
    value = float(value)
    if unit == "s":
        return value * 1000.0
    return value  # already in ms

def parse_log(filepath):
    client_times = []
    avg_write = None
    avg_read = None

    with open(filepath, "r") as f:
        for line in f:
            if "client compute time" in line:
                m = client.search(line)
                if m:
                    client_times.append(convert_to_ms(m.group(1), m.group(2)))

            elif "average write operation time" in line:
                m = write_op.search(line)
                if m:
                    avg_write = convert_to_ms(m.group(1), m.group(2))

            elif "average read operation time" in line:
                m = read_op.search(line)
                if m:
                    avg_read = convert_to_ms(m.group(1), m.group(2))

    # Remove first entry before calculating average because this would falsify result
    if len(client_times) > 1:
        times_no_first = client_times[1:]
        avg_client_time = sum(times_no_first) / len(times_no_first)
    else:
        avg_client_time = None

    return avg_client_time, avg_write, avg_read


def parse_filename(fname): # e.g. client_99_16KB.log
    m = re.match(r"client_(\d+)_(\d+)KB\.log", fname)
    if not m:
        return None
    rows_minus_1 = int(m.group(1))
    datasize_kb = int(m.group(2))

    rows = rows_minus_1 + 1
    datasize = datasize_kb * 1000
    return rows, datasize


log_index = {}
for f in os.listdir(LOG_DIR):
    if f.endswith(".log"):
        parsed = parse_filename(f)
        if parsed:
            log_index[parsed] = os.path.join(LOG_DIR, f)

combined_rows = []

for datasize in datasizes:
    combined_rows.append([f"Datasize {datasize} = rowDataSize"])
    combined_rows.append(["in ms"])
    combined_rows.append(["rows", "avg client time", "write", "read"])

    for rows in rows_list:
        key = (rows, datasize)
        if key in log_index:
            avg_client, avg_write, avg_read = parse_log(log_index[key])
            combined_rows.append([
                rows,
                round(avg_client, 2) if avg_client else "-",
                round(avg_write, 2) if avg_write else "-",
                round(avg_read, 2) if avg_read else "-"
            ])
        else:
            combined_rows.append([rows, "-", "-", "-"])

    combined_rows.append([])
    combined_rows.append([])

df = pd.DataFrame(combined_rows)

with pd.ExcelWriter(OUTPUT_FILE, engine="openpyxl") as writer:
    df.to_excel(writer, sheet_name="All Results", index=False, header=False)

print(f"Wrote results into {OUTPUT_FILE}")
