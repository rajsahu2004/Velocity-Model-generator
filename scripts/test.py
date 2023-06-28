from generator import dispersion_curve_generator

location1 = 'data/homogenous/'
location2 = 'data/two_layer/'
location3 = 'data/three_layer/'

try:
    dispersion_curve_generator(location1,save_plots=True,save_file=True)
    dispersion_curve_generator(location2,save_plots=True,save_file=True)
    dispersion_curve_generator(location3,save_plots=True,save_file=True)
except:
    print("Error in generating the dispersion curve")