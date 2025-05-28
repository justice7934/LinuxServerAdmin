#!/usr/bin/env python3
# 파일명: plot_fio_results.py

import re
import matplotlib.pyplot as plt

# 분석할 로그 파일 목록
files = {
    "ext4": "fio_results/fio_ext4.log",
    "xfs": "fio_results/fio_xfs.log"
}

iops = {}
bandwidth = {}

# 단위 변환 함수
def parse_bw(value, unit):
    unit = unit.lower()
    multiplier = {
        "kb": 1 / 1024,
        "mb": 1,
        "gb": 1024
    }
    return float(value) * multiplier.get(unit, 1)

# 로그 파싱
for fs, filename in files.items():
    with open(filename) as f:
        content = f.read()

        # IOPS
        m = re.search(r"IOPS=(\d+)", content)
        iops[fs] = int(m.group(1)) if m else 0

        # Bandwidth
        m = re.search(r"BW=([\d.]+)([KMG]i?)B/s", content)
        if m:
            value = float(m.group(1))
            unit = m.group(2)
            bw_mb = parse_bw(value, unit)
            bandwidth[fs] = round(bw_mb, 2)
        else:
            bandwidth[fs] = 0

# 📊 그래프 출력
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))
fs_names = list(files.keys())

# IOPS
ax1.bar(fs_names, [iops[fs] for fs in fs_names], color=["steelblue", "salmon"])
ax1.set_title("IOPS 비교")
ax1.set_ylabel("IOPS")

# Bandwidth
ax2.bar(fs_names, [bandwidth[fs] for fs in fs_names], color=["steelblue", "salmon"])
ax2.set_title("Bandwidth (MB/s) 비교")
ax2.set_ylabel("MB/s")

plt.tight_layout()
plt.savefig("fio_results/fio_comparison.png")
plt.show()
