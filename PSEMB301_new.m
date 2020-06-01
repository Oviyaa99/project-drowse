function PSEMB301
%run this function to connect and plot raw EEG data
%make sure to change portnum1 to the appropriate COM port

clear all
close all

data_BLINK = zeros(1,256);    %preallocate buffer
data_ATTENTION = zeros(1,256);
X= zeros(1,256);
   
   
portnum1 =4;   %COM Port of Bluetooth#
comPortName1 = sprintf('\\\\.\\COM%d', portnum1);


% Baud rate for use with TG_Connect() and TG_SetBaudrate().
TG_BAUD_115200  =   115200;

% Data format for use with TG_Connect() and TG_SetDataFormat().
TG_STREAM_PACKETS =     0;


% Data type that can be requested from TG_GetValue().

TG_DATA_BATTERY            =    0 ;   
TG_DATA_POOR_SIGNAL        =    1 ;
TG_DATA_ATTENTION          =    2 ;
TG_DATA_MEDITATION         =    3 ;
TG_DATA_RAW                =    4 ;
TG_DATA_DELTA              =    5 ;
TG_DATA_THETA              =    6 ; 
TG_DATA_ALPHA1             =    7 ;
TG_DATA_ALPHA2             =    8 ;
TG_DATA_BETA1              =    9 ;
TG_DATA_BETA2              =    10 ;
TG_DATA_GAMMA1             =    11 ;
TG_DATA_GAMMA2             =    12 ;
TG_DATA_BLINK_STRENGTH     =    37 ;
TG_DATA_READYZONE          =    38 ;



%load thinkgear dll
loadlibrary('Thinkgear.dll');
fprintf('Thinkgear.dll loaded\n');


%%
% Get a connection ID handle to ThinkGear
connectionId1 = calllib('Thinkgear', 'TG_GetNewConnectionId');
if ( connectionId1 < 0 )
    error( sprintf( 'ERROR: TG_GetNewConnectionId() returned %d.\n', connectionId1 ) );
end;

% Set/open stream (raw bytes) log file for connection
errCode = calllib('Thinkgear', 'TG_SetStreamLog', connectionId1, 'streamLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetStreamLog() returned %d.\n', errCode ) );
end;

% Set/open data (ThinkGear values) log file for connection
errCode = calllib('Thinkgear', 'TG_SetDataLog', connectionId1, 'dataLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetDataLog() returned %d.\n', errCode ) );
end;

% Attempt to connect the connection ID handle to serial port "COM3"
errCode = calllib('Thinkgear', 'TG_Connect',  connectionId1,comPortName1,TG_BAUD_115200,TG_STREAM_PACKETS );
if ( errCode < 0 )
    error( sprintf( 'ERROR: TG_Connect() returned %d.\n', errCode ) );
    
else disp('conected!!');
end

% fprintf( 'Connect    
if(calllib('Thinkgear','TG_EnableBlinkDetection',connectionId1,1)==0)
    disp('blinkdetectenabled');
end
%For Mouse Control


%%
%record data

j = 0;
i = 0;
k = 0;
l = 0;
Blink=0;
Drive_mode = 0;
count = 0;
mouse_x=300;
mouse_y=300;

X = 0:1:255;
%Mosue_CNTRL.fig;
while (i < 100)   %loop for 20 seconds
    
    if (calllib('Thinkgear','TG_ReadPackets',connectionId1,1) == 1)   %if a packet was read...
        
       if (calllib('Thinkgear','TG_GetValueStatus',connectionId1,TG_DATA_BLINK_STRENGTH ) ~= 0)   %if RAW has been updated 
                j = j + 1;
                
                data_BLINK (j)=calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_BLINK_STRENGTH );
                disp('BLINK = ');
                disp(data_BLINK (j));
                if (data_BLINK (j))>90
                    delete(instrfind)
                    pause(3)
                    serialone=serial('COM9','BaudRate',9600);
                    pause(2)
                    fopen(serialone)
                    pause(2)
                    fprintf(serialone,'A');
                    pause(3)
                    fclose(serialone);
                    disp('data sent')
                end
                
%                 if(data_BLINK(j) > 5 )
%                         Blink = Blink+1;
%                 end
% 
%                  if(Blink == 3)
%                     Blink=0;
%                     Drive_mode =1;
%                     open('BrainWave.exe');
%                      mouse.mouseMove(mouse_x, mouse_y);
%                  end
%                 
%                 if(Drive_mode == 1)
%                     if(Blink == 2)
%                         Blink=0;
%                         count = count+1;
%                         if(count==1)
%                             mouse.mouseMove(mouse_x +400, mouse_y);
%                         end
%                         if(count==2)
%                             count = 0;
%                             mouse.mouseMove(mouse_x , mouse_y);
%                         end
%                     end
%                 end

 %      else Blink=0;
           
       end 
       
    
       
        if(Drive_mode == 1)   
            if (calllib('Thinkgear','TG_GetValueStatus',connectionId1,TG_DATA_ATTENTION ) ~= 0)   %if RAW has been updated 
                k = k + 1;
                i = i + 1;
                data_ATTENTION(k) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_ATTENTION);
                disp('ATTENTION = ');
                disp(data_ATTENTION(k));

%                 if(data_ATTENTION(k)>20)
%                     mouse.mousePress(InputEvent.BUTTON1_MASK)
%                     mouse.mouseRelease(InputEvent.BUTTON1_MASK);
%                 end
                plot(X,data_ATTENTION,'-r',X,data_BLINK,'*K');
                axis([0 100 0 200])
                drawnow;
            end
        end    
           
    end
  
end

        
%disconnect             
calllib('Thinkgear', 'TG_FreeConnection', connectionId2 );

