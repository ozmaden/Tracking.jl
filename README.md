[![pipeline status](https://git.rwth-aachen.de/nav/Tracking.jl/badges/master/pipeline.svg)](https://git.rwth-aachen.de/nav/Tracking.jl/commits/master)
[![coverage report](https://git.rwth-aachen.de/nav/Tracking.jl/badges/master/coverage.svg)](https://git.rwth-aachen.de/nav/Tracking.jl/commits/master)
# Tracking
Tracks GNSS signals. Currently it only provides a tracking loop without carrier aiding and without external velocity aiding.

## Features

* DLL/PLL Discriminators
* Loop Filters of 1st, 2nd, and 3rd order
* DLL/PLL loop functions
* a tracking_loop with carrier and external velocity aiding

## Getting started

Install:
```julia
Pkg.clone("git@git.rwth-aachen.de:nav/GNSSSignals.jl.git")
Pkg.clone("git@git.rwth-aachen.de:nav/Tracking.jl.git")
```

## Usage

```julia
    using Tracking
    function beamform(x)
        [0.5 0.5 0.5 0.5] * x
    end
    scale_factor = 1.023e6/1575.43e6 #for L1 Signal
    velocity_aiding = 0.0 #optional
    test_signal = cis.(2 * π * 10 / 120 * (1:12))
    incoming_signals = [test_signal, test_signal, test_signal, test_signal]
    tracking_loop = Tracking.init_tracking(Tracking.init_PLL, Tracking.init_DLL, 0, 50, 0, 1023e3, 1e-3, 4e6, beamform, 12, 18.0, 1.0, 1, scale_factor)
    next_tracking_loop, code_phase, prompt_correlated_signal, prompt_beamformed_signal = tracking_loop(incoming_signals,velocity_aiding)
```

## Todo


## Nice to have

* Multi Signal (satellite) support

## License

MIT License
