clear all;
close all;

#### Define Environment ####
global k = 10;  # spring constant
global g = 10;  # gravitatonal acceleration
global m = 1;   # mass of bob
# Define Initial conditions (Boundary Conditions) #
global l_ini     = 1;    # initial extent L is streched to
global l0        = 0.5;  # L0 the extention when m = 0
global theta_ini = 0.4;  # initial displacement of pendulum

## Simulation Control ##
global t_delta = 0.001;  # accuracy (simulation in steps of delta t)
T_max   = 30;    # number of units of time to simulate

## plot controls ##
lim = 1.5;  # the lim of the box containing the pendulum
FPS = 20; # frames per unit time
plot_l_theta = 1; # set to 1 if you want to plot l vs theta and related data

###------------------------- begin script -------------------------###
# pendulum structure
global pendulum;

# set the acceleration values at this instant
function update_acceleration ()
	global pendulum;
	global g;
	global m;
	global k;
	global l0;

	pendulum.la      = g * cos(pendulum.theta) - k*(pendulum.l - l0) / m;
	pendulum.theta_a = - g * sin(pendulum.theta) / pendulum.l;
endfunction

# initialise pendulum structure
function initialise_pendulum ()
	global pendulum;
	global l_ini;
	global theta_ini

	pendulum.l  = l_ini;
	pendulum.lv = 0;
	pendulum.theta   = theta_ini;
	pendulum.theta_v = 0;

	update_acceleration();
endfunction

# update pendulum to values after a small time t_delta passes
function update_pendulum ()
	global pendulum;
	global t_delta;

	pendulum.lv += pendulum.la * t_delta;
	pendulum.l  += pendulum.lv * t_delta + pendulum.la * t_delta^2 / 2;

	pendulum.theta_v += pendulum.theta_a * t_delta;
	pendulum.theta   += pendulum.theta_v * t_delta + pendulum.theta_a * t_delta^2 / 2;

	update_acceleration();
endfunction

# frames per unit
fp_unit = FPS;
# number of t_deltas between frames
tp = 1 / fp_unit / t_delta;
# counter for plot
cnt = 0;
# counter for data collection
n   = 1;

## Set up plot
figure(1);
clf;
subplot(1,2,1);
cla;
subplot(1,2,2);
cla;

# arrays to collect data
L_data(n)     = 0;
Theta_data(n) = 0;
t_data        = 0:t_delta:T_max;;

#initialise
initialise_pendulum();
#measure execution time
tstart2 = tstart = clock();
for t = t_data;

	if(!mod(cnt,tp))
		# plot 1 (visualisation of pendulum)
		subplot(1,2,1);
		h = quiver(0,0, pendulum.l * sin(pendulum.theta), -pendulum.l * cos(pendulum.theta), "k", "linewidth", 1);
		set(h, "maxheadsize", 0.0);
		axis([-lim, lim, -2*lim, 0], "equal");
		grid("on");
		title(sprintf("t = %0.2f",t));
		# plot 2 (trajectory equation)
		subplot(1,2,2);
		hold "on";
		plot(pendulum.l * sin(pendulum.theta) ,-pendulum.l * cos(pendulum.theta), "*r", "markersize", 3);
		axis([-lim, lim, -2*lim, 0], "equal");
		grid("on");
		title(sprintf("t = %0.2f",t));
		## subract execution time
		exe_time = etime(clock(), tstart);
		pause(t_delta * tp - exe_time);
	endif
	cnt++;
	## collect data
	if(plot_l_theta)
		L_data(n)     = pendulum.l;
		Theta_data(n) = pendulum.theta;
		n++;
	endif

	update_pendulum();
endfor
# print total execution time
exe_time = etime(clock(), tstart2);
printf("t = %f\n",exe_time);

if(plot_l_theta)
	## setup second figure
	figure(2);
	clf;
	subplot(1,2,1);
	cla;
	subplot(1,2,2);
	cla;
	# plot 1 (l vs theta)
	subplot(1,2,1);
	plot(Theta_data, L_data,"-r" , "linewidth", 1);
	axis([-theta_ini, theta_ini, min(L_data), max(L_data)]);
	grid("on");
	title("L vs theta");
	xlabel("theta");
	ylabel("L");
	#plot 2 (l and theta vs t)
	subplot(1,2,2);
	hold "on";
	plot(t_data, Theta_data, "-b", "linewidth", 1);
	plot(t_data, L_data, "-r" , "linewidth", 1);
	legend("theta","L");
	axis([0, T_max, min(Theta_data), max(L_data)]);
	grid("on");
	title("L and theta vs t");
	xlabel("t");
endif
