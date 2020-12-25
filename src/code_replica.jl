"""
$(SIGNATURES)

CPU Code replica function
"""
function gen_code_replica!(
    code_replica,
    system,
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
)
    fixed_point = sizeof(Int) * 8 - 1 - min_bits_for_code_length(system)
    delta = floor(Int, code_frequency * 1 << fixed_point / sampling_frequency)
    modded_start_code_phase = mod(
        start_code_phase,
        get_code_length(system) * get_secondary_code_length(system)
    )
    fixed_point_start_code_phase = floor(Int, modded_start_code_phase * 1 << fixed_point)
    max_sample_shift = maximum(early_late_sample_shift)
    # Assumes, that the number of early shifts is identical to the number of late shifts
    early_late_samples = 2 * max_sample_shift
    @inbounds for i = start_sample:num_samples + early_late_samples + start_sample - 1
        fixed_point_code_phase = (i - max_sample_shift - start_sample) * delta +
            fixed_point_start_code_phase
        code_index = fixed_point_code_phase >> fixed_point
        code_replica[i] = get_code_unsafe(system, code_index, prn)
    end
    code_replica
end

"""
$(SIGNATURES)

GPU Code replica function
"""
function gen_code_replica!(
    code_replica::CuArray{T},
    system,
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
) where T
    idxs = start_sample:start_sample - 1 + num_samples + 2*early_late_sample_shift
    phases = code_frequency .* (0:num_samples - 1 + 2 * early_late_sample_shift) ./ sampling_frequency .+ start_code_phase
    code_length = get_code_length(system) * get_secondary_code_length(system)
    @inbounds @views code_replica[idxs] .= system.codes[2 .+ mod.(floor.(Int, phases), code_length), prn]
    return code_replica
end

"""
$(SIGNATURES)

Updates the code phase.
"""
function update_code_phase(
    gnss::S,
    num_samples,
    code_frequency,
    sampling_frequency,
    start_code_phase,
    secondary_code_or_bit_found
) where S <: AbstractGNSSSystem
    if get_data_frequency(gnss) == 0Hz
        secondary_code_or_bit_length = get_secondary_code_length(gnss)
    else
        secondary_code_or_bit_length =
            Int(get_code_frequency(gnss) / (get_data_frequency(gnss) * get_code_length(gnss)))
    end
    code_length = get_code_length(gnss) *
        (secondary_code_or_bit_found ? secondary_code_or_bit_length : 1)
    mod(code_frequency * num_samples / sampling_frequency + start_code_phase, code_length)
#    fixed_point = sizeof(Int) * 8 - 1 - min_bits_for_code_length(S)
#    delta = floor(Int, code_frequency * 1 << fixed_point / sampling_frequency)
#    fixed_point_start_phase = floor(Int, start_code_phase * 1 << fixed_point)
#    phase_fixed_point = delta * num_samples + fixed_point_start_phase
#    mod(phase_fixed_point / 1 << fixed_point, code_length)
end

"""
$(SIGNATURES)

Calculates the current code frequency.
"""
function get_current_code_frequency(gnss, code_doppler)
    code_doppler + get_code_frequency(gnss)
end
