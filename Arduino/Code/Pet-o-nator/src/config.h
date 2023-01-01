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

// Configuring Motor
#define MotorPwmPin 10
#define MotorFeedbackPin 2

// Configuring Hot End
#define HotEndPwmPin 9
#define HotEndNtcRead A0
#define HotEndRSelection 7
#define HotEndSenseResistor1 9800.0
#define HotEndSenseResistor2 555.0
#define HotEndKp 30.0
#define HotEndKi 3.5
#define HotEndKd 15.5

// double Kp = 120, Ki = 14, Kd = 60;

// Configuring Display
#define DisplayRefreshTime 128UL // The amount of time between two refreshes