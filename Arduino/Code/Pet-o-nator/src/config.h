// Configuring keyboard
#define keboardBits 3
#define keboardA0 11
#define keboardA1 12
#define keboardA2 13
#define tempUp 1
#define tempDown 2
#define speedUp 4
#define speedDown 5
#define startButton 8
#define stopButton 7
#define preSetButton 9

// Configuring Motor
#define MotorPwmPin 10
#define MotorFeedbackPin 2
#define MotorPreSetRpm 1500
#define MotorSpeedToRpm 97          // Reduction reatio of the gearbox
#define MotorPulsesPerRevolution 13 // How many pulses represent one turn of the motor
#define MotorKp 1                   // Proportional PID constant
#define MotorKi 0                   // Integral PID constant
#define MotorKd 0                   // Derivative PID constant
#define MotorTimeOut 300            // How many ms to wait until consider the motor has stoped

// Configuring Hot End
#define HotEndPwmPin 9
#define HotEndNtcRead A0
#define HotEndRSelection 7
#define HotEndSenseResistor1 9800.0
#define HotEndSenseResistor2 555.0
#define HotEndPreSetTemperature 486.15 // Preset temp in K
/*Results from Ziegler–Nichols method:
 *Ku=100
 *Tu=13.438s
 *Taking from the table in https://en.wikipedia.org/wiki/Ziegler%E2%80%93Nichols_method
 *Kp = 0.2*Ku = 20.0
 *Ki = 0.4*Ku/Tu = 2.97
 *Kd = 2*Ku*Tu/30 = 89.6
 */
#define HotEndKp 20.0
#define HotEndKi 2.97
#define HotEndKd 89.6

// Configuring Display
#define DisplayRefreshTime 128UL // The amount of time between two refreshes