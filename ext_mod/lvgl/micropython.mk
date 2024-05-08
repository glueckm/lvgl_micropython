
################################################################################
# LVGL build rules


MOD_DIR := $(USERMOD_DIR)
LVGL_BINDING_DIR = $(subst /ext_mod/lvgl,,$(MOD_DIR))

LVGL_DIR = $(LVGL_BINDING_DIR)/lib/lvgl
LVGL_ADDON_DIR = $(LVGL_BINDING_DIR)/ext_mod/lvgl_addons
LVGL_HEADER = $(LVGL_BINDING_DIR)/build/lvgl_header.h

CFLAGS_USERMOD += -I$(LVGL_BINDING_DIR)
CFLAGS_USERMOD += -I$(LVGL_DIR)
CFLAGS_USERMOD += -I$(LVGL_BINDING_DIR)/include

ifdef $(LV_CFLAGS)
    CFLAGS_USERMOD += $(LV_CFLAGS)
endif

ifneq (,$(findstring -Wno-missing-field-initializers, $(CFLAGS_USERMOD)))
    CFLAGS_USERMOD += -Wno-missing-field-initializers
endif

ALL_LVGL_SRC = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LVGL_BINDING_DIR)/lib/lv_conf.h

LVGL_MPY = $(BUILD)/lv_mpy.c
LVGL_MPY_METADATA = $(BUILD)/lv_mpy.json


SRC_USERMOD_LIB_C += $(shell find $(LVGL_DIR)/src -type f -name "*.c")
SRC_USERMOD_LIB_C += $(LVGL_ADDON_DIR)/src/color_addons.c
SRC_USERMOD_C += $(LVGL_MPY)

ifneq (,$(findstring stm32, $(LV_PORT)))
    CFLAGS_USERMOD += -DMP_SOFT_MATH=1
    SRC_USERMOD_LIB_C += $(LVGL_ADDON_DIR)/src/soft_math.c
endif

ifneq (,$(findstring rp2, $(LV_PORT)))
    CFLAGS_USERMOD += -DMP_SOFT_MATH=1
    SRC_USERMOD_LIB_C += $(LVGL_ADDON_DIR)/src/soft_math.c
endif

$(LVGL_MPY): $(ALL_LVGL_SRC) $(LVGL_BINDING_DIR)/gen/$(GEN_SCRIPT)_api_gen_mpy.py
	$(ECHO) "LVGL-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/$(GEN_SCRIPT)_api_gen_mpy.py $(LV_CFLAGS) --board=$(LV_PORT) --output=$(LVGL_MPY) --include=$(LVGL_BINDING_DIR) --include=$(LVGL_DIR) --include=$(LVGL_BINDING_DIR)/include --module_name=lvgl --module_prefix=lv --metadata=$(LVGL_MPY_METADATA) --header_file=$(LVGL_HEADER)

.PHONY: LVGL_MPY
LVGL_MPY: $(LVGL_MPY)

