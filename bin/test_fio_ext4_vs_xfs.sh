#!/bin/bash
# 파일명: test_fio_ext4_vs_xfs.sh

# 테스트용 loopback 디스크 크기
DISK_SIZE=2G
LOOP_FILE=/tmp/testdisk.img

# FIO 공통 설정
FIO_RUNTIME=60       # 초 단위
FIO_BLOCKSIZE=4k
FIO_NUMJOBS=4
FIO_SIZE=1G

# 결과 디렉터리
RESULT_DIR=$(pwd)/fio_results
mkdir -p "$RESULT_DIR"

# 테스트 함수
run_fio_test() {
    local mount_point=$1
    local fs_type=$2

    echo "[*] ${fs_type} 테스트 시작..."

    fio --name="${fs_type}_randrw" \
        --directory="$mount_point" \
        --rw=randrw \
        --bs=$FIO_BLOCKSIZE \
        --numjobs=$FIO_NUMJOBS \
        --size=$FIO_SIZE \
        --runtime=$FIO_RUNTIME \
        --group_reporting \
        --time_based \
        > "$RESULT_DIR/fio_${fs_type}.log"

    echo "[+] ${fs_type} 결과 저장됨: $RESULT_DIR/fio_${fs_type}.log"
}

# 기존 파일 제거
sudo umount /mnt/fio_test &>/dev/null
sudo losetup -D
sudo rm -f "$LOOP_FILE"

# 디스크 이미지 생성
dd if=/dev/zero of=$LOOP_FILE bs=1M count=5120 status=progress
LOOP_DEV=$(sudo losetup --show -f "$LOOP_FILE")

# ext4 테스트
sudo mkfs.ext4 -F "$LOOP_DEV"
sudo mkdir -p /mnt/fio_test
sudo mount "$LOOP_DEV" /mnt/fio_test
sudo chown $(id -u):$(id -g) /mnt/fio_test
run_fio_test /mnt/fio_test ext4
sudo umount /mnt/fio_test

sleep 5

# xfs 테스트
sudo mkfs.xfs -f "$LOOP_DEV"
sudo mount "$LOOP_DEV" /mnt/fio_test
sudo chown $(id -u):$(id -g) /mnt/fio_test
run_fio_test /mnt/fio_test xfs
sudo umount /mnt/fio_test

# 정리
sudo losetup -d "$LOOP_DEV"
rm -f "$LOOP_FILE"

echo -e "\n📊 테스트 완료! 결과 위치: $RESULT_DIR"
