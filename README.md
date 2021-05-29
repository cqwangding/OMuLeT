# OMuLeT: Online Multi-Lead Time Location Prediction for Hurricane Trajectory Forecasting

## Project Details

The OMuLeT Algorithm was implemented using Matlab.

v1: This is the OMuLeT implementation that produced the experiment results in the paper. It applied on the hurricane trajectory dataset collected from year 2012 to 2018. Execute run.m in Matlab environment to generate all the experiment results.

v2: This is the current version of OMuLeT implementation. It applied on the hurricane trajectory dataset collected from year 2012 to 2020. Execute run.m in Matlab environment to generate all the experiment results.

The following description is based on the Matlab code v2.

## Dataset

The ground truth hurricane trajectory data along with the official forecasts are obtained from the National Hurricane Center (NHC) website: [https://www.nhc.noaa.gov](https://www.nhc.noaa.gov)

The ensemble member forecasts are obtained from the Hurricane Forecast Model Output website at University of Wisconsin-Milwaukee: [http://derecho.math.uwm.edu/models](http://derecho.math.uwm.edu/models)

We collected 6-hourly hurricane trajectory data from the year 2012 to 2020, which contains 336 tropical cyclones. Each tropical cyclone has an average length of 21.9 time steps (data points), which gives a total of 7364 data points. There are 27 trajectory forecast models used in our experiments, which are a subset of the models used by NHC in the preparation of their official forecasts. The data from 2012 to 2017 (208 tropical cyclones) are used for  training and validation, while those from 2018 to 2020 (128 tropical cyclones) are used for testing.

In data folder, the variables saved in each file are described as follows:

| Filename          | Variable description                                         |
| ----------------- | ------------------------------------------------------------ |
| forecasts_tra.mat | X: size 27x2x9x7364, 27 models, latitude and longitude, current location + 1-8 lead times forecasts, 7364 time steps |
|                   | Y: size 2x9x7364, best track location for corresponding X    |
|                   | NHC: size 2x9x7364, official forecasts from NHC              |
|                   | time: size 336x2,  start time step and end time step for 336 hurricanes |
|                   | splits: size 3x2, start hurricane number and end hurricane number for model training, validation and testing |
| hurricane.mat     | hurricane: size 1x336, contains hurricane id, name, location (Atlantic, Eastern and Central Pacific), start time and end time |
| model.mat         | model: 1x167, contains model id, type and interval (6-hour, 12-hour) |
| predict_flag.mat  | predict_flag: 9x7364, marked whether any model output is collected at each time step and lead time |
| predict.mat       | predict: saved baseline predictions and OMuLeT predictions   |

## Parameters for OMuLeT Algorithm

The parameters for OMuLeT algorithm are described as follows:

| Parameter name   | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| opts.error_type  | 1: distance loss, 2: L1 loss, 3: L2 loss                     |
| opts.unit_change | The final output will be divided by this variable for unit change purpose |
| opts.use_predict | In backtracking and restart, the forecasts generated at current time step can be used as ground truth in the past time step. In our experiments, this technique can further improve the hurricane trajectory predictions but not intensity predictions. |
| opts.geo         | Whether the input features are geographic data (latitude, longitude) |
| opts.rho         | Hyperparameter ρ, controls the trade off between using the weights from current and past hurricane |
| opts.gamma       | Hyperparameter γ, determines the relative importance of making accurate forecasts at different lead times. |
| opts.omega       | Hyperparameter ω, ensures smoothness in the model parameters for different lead times |
| opts.mu          | Hyperparameter μ, designed to ensure the hurricane-specific factor **u** do not change rapidly from their previous values at time t−1 |
| opts.nu          | Hyperparameter ν, designed to ensure the lead time adjustment **v** do not change rapidly from their previous values at time t−1 |
| opts.eta         | Hyperparameter η, imposes a  sparsity constraint on the lead time adjustment factor |

## Results

| Algorithm name | 12 hour forecast error (n mi) | 24 hour forecast error (n mi) | 36 hour forecast error (n mi) | 48 hour forecast error (n mi) |
| -------------- | ----------------------------- | ----------------------------- | ----------------------------- | ----------------------------- |
| Ensemble Mean  | 23.30                         | 36.34                         | 50.22                         | 65.03                         |
| Persistence    | 34.84                         | 88.89                         | 155.87                        | 229.63                        |
| PA             | 23.30                         | 36.34                         | 50.23                         | 64.80                         |
| ORION          | 23.37                         | 36.36                         | 50.21                         | 65.00                         |
| NHC            | 24.59                         | 38.49                         | 52.17                         | 65.74                         |
| OMuLeT         | 22.20                         | 34.94                         | 48.07                         | 62.10                         |

## Cite OMuLeT

If you find OMuLeT or hurricane dataset useful for your research, please consider citing our paper:

```
@inproceedings{wang2020omulet,
  title={{OMuLeT: Online Multi-Lead Time Location Prediction for Hurricane Trajectory Forecasting}},
  author={
  Wang, Ding and Liu, Boyang and Tan, Pang-Ning and Luo, Lifeng},
  booktitle={Proceedings of 34th AAAI Conference on Artificial Intelligence},
  year={2020}
}
```

