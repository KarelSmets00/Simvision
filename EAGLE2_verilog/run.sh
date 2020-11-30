
# Source the tools
if ! [ -x "$(command -v ncvlog)" ]; then
  source /esat/micas-data/data/design/scripts/xcelium_19.03.rc
  echo "INFO: sourced ncvlog as simulator."
fi


if ! [ -x "$(command -v spectre)" ]; then
  source /esat/micas-data/data/design/scripts/spectre_19.10.rc
  echo "INFO: sourced spectre as analog simulator."
fi

# Run without simvision (no wavefroms visible)
#xrun ./amsSim.scs -spectre_args "+ms ++aps=liberal" -f verilogFiles.f -access +rwc -64bit -gui

# Run with simvision, you can select the waveforms you want to see. The out value of R_NETWORK should look like a ugly staircase.
xrun ./amsSim.scs -spectre_args "+ms ++aps=liberal" -f verilogFiles.f -access +rwc -64bit -gui
