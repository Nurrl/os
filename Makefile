ASM			:= nasm
ASMFLAGS	:= -w+all -f bin

SRC_DIR		:= src
BUILD_DIR	:= build

IMG_NAME	:= os.img
IMG_PATH	:= $(BUILD_DIR)/$(IMG_NAME)

all: image

run: image
	qemu-system-x86_64 $(IMG_PATH)

debug: image
	bochs -f .bochsrc

image: bootloader kernel
	# Create a FAT12 disk image
	dd if=/dev/zero of="$(IMG_PATH)" bs=512 count=2880
	mkfs.fat -F 12 -n "OS" "$(IMG_PATH)"

	# Burn the bootloader at 0x3E
	dd if="$(BUILD_DIR)/bootloader.bin" of="$(IMG_PATH)" bs=62 seek=1 conv=notrunc
	# Copy the kernel into the image
	mcopy -i "$(IMG_PATH)" "$(BUILD_DIR)/kernel.bin" "::kernel.bin"

bootloader: $(BUILD_DIR)/bootloader.bin

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/%.bin: $(SRC_DIR)/%/main.s
	$(ASM) $(ASMFLAGS) -i "$(shell dirname $<)" -o "$@" "$<"

clean:
	rm -f "$(BUILD_DIR)/"*".bin"

fclean: clean
	rm -f "$(IMG_PATH)"

.PHONY: run all image bootloader kernel clean fclean
