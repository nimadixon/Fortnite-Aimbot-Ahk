; Autokick Edit 

init:
#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
 

SetKeyDelay, -1, 1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
 
; Initial color settings
EMCol := 0xF9F8F7 ; Initial color (yellow)
ColVn := 50 ; Reduced color variance for better precision
ZeroX := 640
ZeroY := A_ScreenHeight // 2
CFovX := A_ScreenWidth // 44.75 ; Adjusted field of view for precision
CFovY := A_ScreenHeight // 44.75 ; Adjusted field of view for precision
 
; Adaptive Field of View
MinFovX := A_ScreenWidth // 44.75
MinFovY := A_ScreenHeight // 44.75
MaxFovX := A_ScreenWidth // 90
MaxFovY := A_ScreenHeight // 90
 
; Kalman filter variables
KalmanX := 0
KalmanY := 0
KalmanP := 2
KalmanQ := 1.5 ; Further fine-tuned process noise covariance
KalmanR := 0.05 ; Further fine-tuned measurement noise covariance for better precision
KalmanVx := 0   ; Velocity in X
KalmanVy := 0   ; Velocity in Y
 
; Default Sensitivity
global Sensitivity := 1.35


        ; جستجو در محدوده مشخص (x=700 تا x=800 و y=250 ثابت)
        ScanL := 620  ; x شروع640
        ScanT := 192  ; y ثابت
        ScanR := 660  ; x پایان
        ScanB := 192 ; y ثابت (برای جستجو در همان سطح y)
 
Loop {


        PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, ColVn, Fast RGB
        if (!ErrorLevel) {
            ; فقط محاسبه تغییرات x (y ثابت باقی می‌ماند)
            AimX := (AimPixelX - 1) - ZeroX
            DirX := (AimX > 0) ? 1 : -1

            ; Dynamic Sensitivity Adjustment
            Distance := Abs(AimX)
            LocalSensitivity := Sensitivity

            MoveX := Floor(Sqrt(Distance)) * DirX * LocalSensitivity

            ; Kalman filter: Predict
            KalmanX := KalmanX + KalmanVx
            KalmanP := KalmanP + KalmanQ

            ; Kalman filter: Update
            K := KalmanP / (KalmanP + KalmanR)
            KalmanX := KalmanX + K * (MoveX - KalmanX)
            KalmanVx := K * (MoveX - KalmanX)
            KalmanP := (1 - K) * KalmanP

            ; Apply smoothing with EMA (Exponential Moving Average)
            Alpha := 15 ; Adjusted Alpha for better precision
            SmoothedX := (1 - Alpha) * KalmanX + Alpha * MoveX

            ; Move the mouse only on the x-axis (y ثابت است)
            DllCall("mouse_event", uint, 1, int, SmoothedX * 1.35, int, 0, uint, 0, int, 1)
        }
    Sleep, 0 ; Reduced delay for faster response
}

 


i::mousemove,640,190
alt::Pause


 
