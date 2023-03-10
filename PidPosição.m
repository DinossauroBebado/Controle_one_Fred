
% para poder utilizar este scrip, primeiramente inicie o turtlesim node com
% o comando: 
% rosrun turtlesim turtlesim_node

% % rosinit;

% ------- config publisher
msg_twist = rosmessage('geometry_msgs/Twist') ;
pub_twist = rospublisher("/cmd_vel",'geometry_msgs/Twist');

% ------- config subscriber
sub_odom = rossubscriber("/odom");
odom_data = receive(sub_odom,10); 

% ------- inicializar com velocidade 0
msg_twist.Linear.X = 0; 
msg_twist.Angular.Z = 0; 
send(pub_twist,msg_twist);

% setpoint xy
target_x = 9.5;
target_y = 0;

% constantes PID linaer 
kp_linear = 0.5; %1.5
ki_linear = 0.9; %0.9
kd_linear = 0.1; %0.1/

% constantes PID angular
kp_angular = 0.5;  %2.1
ki_angular = 0.5;  %0.1
kd_angular = 0.1;  %0.1


% variavais para calculo deltaT
elapsedTime = 0; 
previous_time = clock;

previous_error_linear = 0;
previous_error_angular = 0; 

vel_linear_integral = 0;
vel_angular_integral = 0; 

error_linear =  99; 
error_angular =  99;   % fazer com que o scrip entre na condição while abaixo

while((abs(error_angular) > 0.1) || (abs(error_linear) > 0.1))
    
    % recebe dados de odometria
    odom_data = receive(sub_odom,10); 
    
    Quaternion_ros = odom_data.Pose.Pose.Orientation ;
    quat = [odom_data.Pose.Pose.Orientation.X odom_data.Pose.Pose.Orientation.Y odom_data.Pose.Pose.Orientation.Z odom_data.Pose.Pose.Orientation.W];
       
    %z in radians de - pi a pi 
    yaw = quat2angle(quat,'XYZ');
    
    error_linear =  hypot((target_y - odom_data.Pose.Pose.Position.Y),(target_x - odom_data.Pose.Pose.Position.X));
        
    setpoint_angle = atan((target_y-odom_data.Pose.Pose.Position.Y)/(target_x-odom_data.Pose.Pose.Position.X));
        
    error_angular = setpoint_angle - yaw;

    % condição para complementar o angulo caso necessário
     yaw = quat2angle(quat,'XYZ');  
    
%      if(error_angular<0 && odom_data.Pose.Pose.Orientation.Z > 0)
%         error_angular = (setpoint_angle - odom_data.Pose.Pose.Orientation.Z) + 2*pi; 
%     end

    % Delta T para calculo de derivada e integral
    elapsedTime = etime(clock, previous_time); 
    
    % ------- integral 
    vel_linear_integral = (error_linear*ki_linear*elapsedTime);
    vel_angular_integral = (error_angular*ki_angular*elapsedTime); 

    % ------- devidada 
    vel_linear_derivative = kd_linear*(error_linear- previous_error_linear)/elapsedTime; 
    vel_angular_derivative = kd_angular*(error_angular - previous_error_angular)/elapsedTime; 

    % ------- proporcional 
    vel_linear_proporcional = error_linear*kp_linear;
    vel_angular_proporcional = error_angular*kp_angular;

    % ------ calculo PID 
    vel_linear = vel_linear_proporcional + vel_linear_integral + vel_linear_derivative; 
    vel_angular = vel_angular_proporcional + vel_angular_integral + vel_angular_derivative; 

    
    fprintf("velocidade angular: %f", vel_angular); 
    if(vel_linear > 0.04 && vel_linear<0.08)
        vel_linear = 0.08;
    end
    if(vel_linear < 0.2 )
        vel_linear = 0;
    end
    if(vel_linear > 0.32)
        vel_linear = 0.32;
    end
        
    msg_twist.Linear.X = vel_linear;
%     msg_twist.Angular.Z = vel_angular;
     msg_twist.Angular.Z = 0;

    send(pub_twist,msg_twist);
    
    previous_time = clock; 

    previous_error_angular = error_angular; 
    previous_error_linear = error_linear;
    
    fprintf("-----------------------------------------"); 
    fprintf("\n");
    
    
    fprintf("X : %f | Y : %f || vel linear: %f | vel angular: %f",odom_data.Pose.Pose.Position.X,odom_data.Pose.Pose.Position.Y, vel_linear,vel_angular); 
  
%     
%     fprintf("erro linear: %f", error_linear); 
%     fprintf("\n");
%     
%     fprintf("erro angular: %f", error_angular); 
%     fprintf("\n");
    
    fprintf("-----------------------------------------"); 
    fprintf("\n");
    

end

msg_twist.Linear.X = 0;
msg_twist.Angular.Z = 0;
    
send(pub_twist,msg_twist);




