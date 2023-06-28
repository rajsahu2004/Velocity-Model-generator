import numpy as np
import matplotlib.pyplot as plt
from disba import PhaseDispersion
import os
import pandas as pd

def location_split(location):
    split = location.split('/')
    return split[-2]

def dispersion_curve_generator(folder_location,save_location='cpr/',save_plots=False,save_file=False):
        files = os.listdir(folder_location)
        folder_type = location_split(folder_location)
        if not os.path.exists(save_location+folder_type+'_plots') and save_plots:
            os.makedirs(save_location+folder_type+'_plots')
        if not os.path.exists(save_location+folder_type+'_files') and save_file:
            os.makedirs(save_location+folder_type+'_files')
        for file_number, file in enumerate(files):
            try:
                file_location = folder_location + file
                model = pd.read_csv(file_location)
                thickness = model['z'].to_numpy() / 1000
                depth = np.round(thickness.sum(),3)
                method = 'passive' if depth < 1 else 'active'
                print(f"\033[94m{file_number+1}. GENERATING CURVE FOR {folder_type.upper()} {method.upper()} MODEL\033[0m")
                v_s = model['Vs'].to_numpy() / 1000
                v_p = model['Vp'].to_numpy() / 1000
                density = model['rho'].to_numpy()
                t = np.round(np.linspace(1/10,1/0.5,100),3)
                
                phDisp = PhaseDispersion(thickness,v_p,v_s,density)
                cpr = [phDisp(t, mode=i, wave="rayleigh") for i in range(3)]
                
                plot_name = f'cpr/{folder_type}_plots/{file_number+1}.png'
                for mode,a in enumerate(cpr):
                    plt.title(f"Rayleigh wave {method} dispersion for {folder_type} layer")
                    if len(a.velocity):
                        plt.plot(a.period, np.round(a.velocity,3), label=f"mode {mode}")
                        plt.xlabel("Period (s)")
                        plt.ylabel("Velocity (km/s)")
                        plt.xscale("log")
                        plt.grid(True)
                        plt.legend()
                        print(f"\033[92m\tMode {mode} exists\033[0m",end=' ')
                if save_plots:
                    plt.savefig(plot_name,dpi=150)
                    plt.close()
                
                file_name = f'cpr/{folder_type}_files/{file_number+1}.txt'
                if save_file:
                    with open(file_name, 'w') as f:
                        f.write('Period (s), Velocity (km/s), Mode\n')
                        for i in range(3):
                            for j in range(len(cpr[i].period)):
                                f.write(f'{cpr[i].period[j]}, {cpr[i].velocity[j]}, {i}\n')
                
                print(f"\033[94m\n\tCurve successfully generated\033[0m")
            except:
                print(f"\033[91m\n\tCurve could not be generated\033[0m")
        print(f"\033[93m{file_number+1} {folder_type} {method} files checked\033[0m")