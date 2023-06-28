import matplotlib.pyplot as plt
import os
import time
import swprocess

main_folder = './seismic_files/'
save_folder = './images/'
if not os.path.exists(save_folder):
    os.mkdir(save_folder)
    print(f'\033[93m{save_folder}\033[0m created')

if not os.path.exists(save_folder + 'homogenous'):
    os.mkdir(save_folder + 'homogenous')
    print(f'\033[93m{save_folder}homogenous\033[0m created')
    
if not os.path.exists(save_folder + 'two_layer'):
    os.mkdir(save_folder + 'two_layer')
    print(f'\033[93m{save_folder}two_layer\033[0m created')
if not os.path.exists(save_folder + 'three_layer'):
    os.mkdir(save_folder + 'three_layer')
    print(f'\033[93m{save_folder}three_layer\033[0m created')

currentFolder = main_folder
currentSaveFolder = save_folder
for folder in os.listdir(currentFolder):
    currentFolder = main_folder + folder
    currentSaveFolder = save_folder + folder
    for each_folder in os.listdir(currentFolder):
        currentSaveFolder = save_folder + folder + '/' + each_folder
        if not os.path.exists(currentSaveFolder):
            os.mkdir(currentSaveFolder)
            print(f'\033[93m{currentSaveFolder}\033[0m created')
        currentFolder = main_folder + folder + '/' + each_folder + '/cut_su'
        currentSaveFolder = save_folder + folder + '/' + each_folder + '/cut_su'
        if not os.path.exists(currentSaveFolder):
            os.mkdir(currentSaveFolder)
            print(f'\033[93m{currentSaveFolder}\033[0m created')
        if not os.path.exists(currentFolder):
            continue
        else:
            files = [currentFolder + '/' + file for file in os.listdir(currentFolder) if file.endswith('.su')]
            for file in files:
                if os.stat(file).st_size:
                    save_file = currentSaveFolder + '/' + file.split('/')[-1].split('.')[0]
                    name=None
                    workflow = "time-domain"
                    trim, trim_begin, trim_end = False, 0.1, 0.9
                    mute, method, window_kwargs = False, "interactive", {}
                    pad, df = True, 0.5
                    transform = "fdbf"
                    fmin, fmax = 0.5, 10
                    vmin, vmax, nvel, vspace = 100, 1350, 100, "linear"
                    fdbf_weighting = "sqrt"
                    fdbf_steering = "cylindrical"
                    snr = False
                    settings = swprocess.Masw.create_settings_dict(
                        workflow=workflow,
                        trim=trim,
                        trim_begin=trim_begin,
                        trim_end=trim_end,
                        mute=mute,
                        method=method,
                        window_kwargs=window_kwargs,
                        transform=transform,
                        fmin=fmin,
                        fmax=fmax,
                        pad=pad,
                        df=df,
                        vmin=vmin,
                        vmax=vmax,
                        nvel=nvel,
                        vspace=vspace,
                        weighting=fdbf_weighting,
                        steering=fdbf_steering,
                        snr=snr
                        )
                    start = time.perf_counter()
                    wavefieldtransforms = swprocess.Masw.run(fnames=file, settings=settings)
                    end = time.perf_counter()
                    print(f"Elapsed Time (s): {round(end-start,2)}")
                    wavefield_normalization = "frequency-maximum"
                    display_lambda_res = False
                    display_nearfield = False
                    wavefieldtransforms.plot()
                    plt.savefig(save_file + '.png',dpi=300)
                    plt.close()
                    print(f'\033[92m{save_file}.png\033[0m Image saved')
                else:
                    print(f'\033[93m{file} is empty\033')