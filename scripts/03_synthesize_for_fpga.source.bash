. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/00_setup.source.bash"

setup_run_directory_for_fpga_synthesis

#-----------------------------------------------------------------------------

> "$log"

if false && is_command_available iverilog
then
    iverilog -g2005-sv \
         -I ..      -I "$lab_dir/common" \
            ../*.sv    "$lab_dir/common"/*.sv \
        |& tee "$log"

    vvp a.out |& tee -a "$log"
fi

#-----------------------------------------------------------------------------

is_command_available_or_error quartus_sh " from Intel FPGA Quartus Prime package"

if ! quartus_sh --no_banner --flow compile fpga_project |& tee -a "$log"
then
    grep -i -A 5 error "$log" 2>&1
    error "synthesis failed"
fi

. "$script_dir/04_configure_fpga.source.bash"
