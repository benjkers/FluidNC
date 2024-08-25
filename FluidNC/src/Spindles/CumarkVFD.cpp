#include "CumarkVFD.h"

#include <algorithm>
bool is_Ccw=false;
namespace Spindles {
    
    void CumarkVFD::direction_command(SpindleState mode, ModbusCommand& data) {
        data.tx_length = 6;
        data.rx_length = 6;

        data.msg[1] = 0x06;  // Function code for writing a single register
        data.msg[2] = 0x00;  // Register address high byte (control word)
        data.msg[3] = 0x01;  // Register address low byte (control word)

        switch (mode) {
            case SpindleState::Cw:
                is_Ccw=false; // Spindle is rotaing clockwise
                data.msg[4] = 0x08;  
                data.msg[5] = 0x82;  // Control word set bit 1 to 1 (Start Drive)
                break;
            case SpindleState::Ccw:
                is_Ccw=true; // Spindle is rotating counterclockwise
                data.msg[4] = 0x08;  
                data.msg[5] = 0x82;  // Control word set bit 1 to 1 (Start Drive)
                break;
            default:  // SpindleState::Disable
                is_Ccw=false; // Stop state does not rotate
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop
                break;
        }
    }


    void IRAM_ATTR CumarkVFD::set_speed_command(uint32_t speed, ModbusCommand& data) {
       
        data.tx_length = 6;
        data.rx_length = 6;

        // Multiply the speed by -1 if the spindle is set to rotate counterclockwise
        if (is_Ccw) {
            speed = static_cast<int32_t>(speed) * -1;
        }

        // limiting speeds
        if (speed < _MinSpeed){
            speed=_MinSpeed;
        }
        if(speed>_MaxSpeed){
            speed=_MaxSpeed;
        }
        data.msg[1] = 0x06;  // Set register command
        data.msg[2] = 0x00;  // Register address high byte(RPM setting register)
        data.msg[3] = 0x02;  // Register address low byte (RPM setting register)
        data.msg[4] = speed >> 8; //(Rpm)
        data.msg[5] = speed & 0xFF;
    }


    VFD::response_parser CumarkVFD::get_current_speed(ModbusCommand& data) {
        data.tx_length = 6;
        data.rx_length = 5;
        
        data.msg[1] = 0x03; // Read Registers Fucntion Code 
        data.msg[2] = 0x01; // High Byte of Register Adress (01.00)(Actual Speed)
        data.msg[3] = 0x00; // Low Byte of Register Adress (01.00)
        data.msg[4] = 0x00; // High Byte Number of Registers
        data.msg[5] = 0x01; // Low Byte Number of Resiters

        return [](const uint8_t* response, Spindles::VFD* vfd) -> bool {
            int16_t spd= (int16_t(response[3]) << 8) | int16_t(response[4]);
            // Store speed for synchronization
            vfd->_sync_dev_speed = abs(spd); // take absolute as speed in reverse is negative  
            return true;
        };
    }
   /*++++
    VFD::response_parser CumarkVFD::get_status_ok(ModbusCommand& data) {
        data.tx_length = 6;
        data.rx_length = 7;

        data.msg[1] = 0x03;  // READ
        data.msg[2] = 0x06;  // Register address, high byte (current fault number)
        data.msg[3] = 0x00;  // Register address, low byte (current fault number)
        data.msg[4] = 0x00;  // Number of elements, high byte
        data.msg[5] = 0x01;  // Number of elements, low byte (1 element)

        return [](const uint8_t* response, Spindles::VFD* vfd) -> bool {
            
            uint16_t status_word = (uint16_t(response[3]) << 8) | uint16_t(response[4]);

            uint16_t fault_present = status_word & 0x0002; // Check Bit 1 of status word 1 (0x0002) for fault status
            uint16_t alarm_present = status_word & 0x0004; // Check Bit 2 of status word 1 (0x0004) for alarm status

            return!(fault_present||alarm_present); // Return false if a fault is present, true otherwise
        };
    } 
*/
    namespace {
        SpindleFactory::InstanceBuilder<CumarkVFD> registration("CumarkVFD");
    }
}
