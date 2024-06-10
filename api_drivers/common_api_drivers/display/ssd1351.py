
from micropython import const  # NOQA

import lvgl as lv  # NOQA
import lcd_bus  # NOQA
import display_driver_framework

_CASET = const(0x15)
_PASET = const(0x75)
_RAMWR = const(0x5C)


class SSD1351(display_driver_framework.DisplayDriver):
    _INVOFF = 0xA6
    _INVON = 0xA7

    def _set_memory_location(self, x1, y1, x2, y2):
        # Column addresses
        param_buf = self._param_buf

        param_buf[0] = (x1 >> 8) & 0xFF
        param_buf[1] = x1 & 0xFF
        param_buf[2] = (x2 >> 8) & 0xFF
        param_buf[3] = x2 & 0xFF

        self._data_bus.tx_param(_CASET, self._param_mv[:4])

        # Page addresses
        param_buf[0] = (y1 >> 8) & 0xFF
        param_buf[1] = y1 & 0xFF
        param_buf[2] = (y2 >> 8) & 0xFF
        param_buf[3] = y2 & 0xFF

        self._data_bus.tx_param(_PASET, self._param_mv[:4])

        return _RAMWR

    def init(self):
        param_buf = bytearray(14)
        param_mv = memoryview(param_buf)

        param_buf[0] = 0x12
        self.set_params(0xFD, param_mv[:1])

        param_buf[0] = 0xB1
        self.set_params(0xFD, param_mv[:1])

        self.set_params(0xAE)

        param_buf[0] = 0xF1
        self.set_params(0xB3, param_mv[:1])

        param_buf[0] = 127
        self.set_params(0xCA, param_mv[:1])

        param_buf[0] = 0x00
        self.set_params(0xA2, param_mv[:1])

        param_buf[0] = 0x00
        self.set_params(0xB5, param_mv[:1])

        param_buf[0] = 0x01
        self.set_params(0xAB, param_mv[:1])

        param_buf[0] = 0x32
        self.set_params(0xB1, param_mv[:1])

        param_buf[0] = 0x05
        self.set_params(0xBE, param_mv[:1])

        self.set_params(0xA6)

        param_buf[0] = 0xC8
        param_buf[1] = 0x80
        param_buf[2] = 0xC8
        self.set_params(0xC1, param_mv[:3])

        param_buf[0] = 0x0F
        self.set_params(0xC7, param_mv[:1])

        param_buf[0] = 0xA0
        param_buf[1] = 0xB5
        param_buf[2] = 0x55
        self.set_params(0xB4, param_mv[:3])

        param_buf[0] = 0x01
        self.set_params(0xB6, param_mv[:1])

        self.set_params(0xAF)
