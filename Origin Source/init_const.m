%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% constants                                      %%                                                %% Version: 1.0_20080901                          %% Programmed by                                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%global CONST_C CONST_F1 CONST_F2 CONST_F5 CONST_LAMBDA1 CONST_LAMBDA2 CONST_LAMBDA5global CONST_R_SV CONST_MU_E CONST_OMEGA_E CONST_R_E CONST_B_E CONST_FLAT_Eglobal MODEL_DLV3_PP MODEL_DLV3_RTK MODEL_SF2030M_PP MODEL_RINEXglobal ANT_GPS702GGL ANT_COMPACTL1L2 ANT_ANT532C ANT_UNKNOWNglobal MODE_Tachikoma MODE_Sin MODE_Joe MODE_AE86 MODEL_DLV3_PP_mat01 MODEL_DLV3_PP_mat02global CONST_GPS_PRNmax CONST_Tau_dglobal CONST_QM_MaskAngle CONST_QM_PolyOrderCONST_C         = 299792458.0;          % velocity of light, m/secCONST_F1        = 1575.42e6;            % L1 frequency, HzCONST_F2        = 1227.60e6;            % L2 frequency, HzCONST_F5        = 1176.45e6;            % L5 frequency, HzCONST_LAMBDA1   = CONST_C/CONST_F1;     % L1 wavelength, mCONST_LAMBDA2   = CONST_C/CONST_F2;     % L2 wavelength, mCONST_LAMBDA5   = CONST_C/CONST_F5;     % L5 wavelength, mCONST_R_SV      = 26561750;             % SV orbit semimajor axis, mCONST_MU_E      = 3.986005e14;          % Earth's grav. parameter (m^3/s^2)CONST_OMEGA_E   = 7292115.1467e-11;     % Earth's angular velocity (rad/s)CONST_R_E       = 6378137;              % Earth's semimajor axis, mCONST_B_E       = 6356752.314;          % Earth's semiminor axis, mCONST_FLAT_E    = 1.0/298.257223563;    % Earth flattening constant% MODEL은 입력 데이터 형태를 결정MODEL_DLV3_PP       = 1;                % NovAtel Post-ProcessingMODEL_DLV3_RTK      = 2;                % NovAtel RTK (serial port)MODEL_SF2030M_PP    = 3;                % NavCom Post-ProcessingMODEL_RINEX         = 4;                % RINEX% MODEL_ProPakG2P_PP  = 5;                % NovAtel% MODEL_Trimble_PP    = 6;                % Trimble% MODEL_Septentrio_PP = 7;                % SeptentrioMODEL_DLV3_PP_mat01 = 8;                % testX_2008070910.gps의 mat 파일 읽음 모드MODEL_DLV3_PP_mat02 = 9;                % testX_2008081215.gps의 mat 파일 읽음 모드MODEL_DLV3_PP_mat03 = 10;               % test_20081010_1.gps의 mat 파일 읽음 모드MODEL_DLV3_PP_mat04 = 11;               % test_20081010_2.gps의 mat 파일 읽음 모드MODEL_DLV3_PP_mat05 = 12;               % testX_20080623.gps의 mat 파일 읽음 모드ANT_GPS702GGL   = 1;                    % NovAtelANT_COMPACTL1L2 = 2;                    % NavComANT_ANT532C     = 3;                    % NovAtelANT_UNKNOWN     = 4;                    % ? (일반적인 성능의 패드 안테나)% ANT_GPS702GG    = 5;                    % NovAtel% ANT_GPS701GG    = 6;                    % NovAtel% 항법 알고리즘 모드MODE_Tachikoma  = 1;                    % 공통 위성 5개 이상인 경우 (공각기동대 인공지능 로봇)MODE_Sin        = 2;                    % 공통 위성 4개인 경우 (AREA 88의 주인공)MODE_Joe        = 3;                    % 사용자 신호만 수신되는 경우 (Tomorrow's Joe에서의 주인공)MODE_AE86       = 4;                    % 위성 신호를 수신하지 못한 경우 (Initial D의 차)% CONST_GPS_PRNmax= 32;                   % GPS PRN 최대값CONST_Tau_d     = 100;                  % Time constant of average (smoothing), s% CONST_QM_MaskAngle  = 5;                % Quality Monitoring Mask Angle, degreeCONST_QM_PolyOrder  = 5;                % Quality Monitoring Polynomial Order