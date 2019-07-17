# LimeSDR-Mini FPGA gateware

This version is a modified version of the LimeSDR-Mini gateware.
This bitstream is optimised for DVBS/DVBS2 use, with support for Upsample, QPSK, 8PSK and
attenuation.

Instead of sending IQ sample directly through the USB link you can send packed symbols.
So instead of using 32bit of data for one symbol this version uses 2bit, the last stage 
in the TX path match the symbols to the QPSK DVBS LUT.

This mod proved to be interesting for architecture like RPi where the USB link is limited.
It allows to either do higher rate links or use upsampling to increase MER.

For information, on a desktop computer this project was tested with a 39MSPS DVBS link.

## Current status

This project is in a really early development status. So it can be buggy !
For now the Timing Analysis reports some problem in clock signals, we will try to fix that 
later. In case of bug you can drop a bug report here or contact either @F5OEOEvariste or 
@natsfr on Twitter.

## How-to use it

/!\ This part is not needed anymore F5OEO's dvbsdr already load the bitstream /!\

### FPGA Side

#### Full project

Clone the repository and follow the commands:

**cd ./LimeSDR-Mini_bitstreams**

In this directory you'll find all generated files.
You can then run:

**LimeUtil --fpga=./LimeSDR-Mini_lms7_trx_HW_1.2_auto.rpd**

This command will flash the bitstream to the MAX10 FPGA.
In case you want to go back to the original bitstream you can use:

**LimeUtil --update**

#### Release

You can simply download the bitstream binary: https://github.com/natsfr/LimeSDR_DVBSGateware/releases/
and flash the FPGA.

### Software Side

On software side, please update https://github.com/F5OEO/dvbsdr and dependencies.
Then activate the FPGA Mapping option: -F (please see documentation to edit scripts correctly)
  
## Licensing

(This project uses the same Licensing as LimeSRD-Mini project)

Please see the COPYING file(s). However, please note that the license terms stated do not extend to any files provided with the Altera design tools and see the relevant files for the associated terms and conditions.
