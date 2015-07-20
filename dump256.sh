sigrok-cli \
  --device beaglelogic \
  --channels 1=CLK,2-9
  --triggers 1=r \
  --wait-trigger \
  --samples 256 \
  --protocol-decoders parallel:wordsize=8 \
  --output-format hex:width=128
