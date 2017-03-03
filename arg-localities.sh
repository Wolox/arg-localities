#!/bin/bash

# Get localities by province for Argentina from Correo Argentino
# Code inspired by: https://github.com/jcodagnone/localidades-ar

# declare Associative arrays (like hashmaps): http://wiki.bash-hackers.org/syntax/arrays
declare -A PROVINCES
PROVINCES['A']='Salta'
PROVINCES['B']='Buenos Aires'
PROVINCES['C']='Ciudad Autónoma de Buenos Aires'
PROVINCES['D']='San Luis'
PROVINCES['E']='Entre Ríos'
PROVINCES['F']='La Rioja'
PROVINCES['G']='Santiago del Estero'
PROVINCES['H']='Chaco'
PROVINCES['J']='San Juan'
PROVINCES['K']='Catamarca'
PROVINCES['L']='la Pampa'
PROVINCES['M']='Mendoza'
PROVINCES['N']='Misiones'
PROVINCES['P']='Formosa'
PROVINCES['Q']='Neuquén'
PROVINCES['R']='Río Negro'
PROVINCES['S']='Santa Fe'
PROVINCES['T']='Tucumán'
PROVINCES['U']='Chubut'
PROVINCES['V']='Tierra del Fuego'
PROVINCES['W']='Corrientes'
PROVINCES['X']='Códroba'
PROVINCES['Y']='Jujuy'
PROVINCES['Z']='Santa Cruz'

rm -rf by-province
mkdir by-province

echo '## Processing all provinces...'
for i in A B C D E F G H J K L M N P Q R S T U V W X Y Z; do
  echo "  ## Processing province ${PROVINCES[${i}]}"
  text="{\"iso_31662\":\"AR-${i}\", \"province\":\"${PROVINCES[${i}]}\", \"localities\":"
  text="${text}`curl -s 'http://www.correoargentino.com.ar/sites/all/modules/custom/ca_forms/api/wsFacade.php' \
  -H 'Cookie: has_js=1; _ga=GA1.3.1461637301.1485963032; __atuvc=1%7C5%2C0%7C6%2C0%7C7%2C0%7C8%2C7%7C9; __atuvs=58b987e75cac7710006' \
  -H 'Origin: http://www.correoargentino.com.ar' -H 'Accept-Encoding: gzip, deflate' \
  -H 'Accept-Language: en-US,en;q=0.8,es;q=0.6' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: http://www.correoargentino.com.ar/formularios/cpa' \
  -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' \
  --data "action=localidades&localidad=none&calle=&altura=&provincia=${i}" --compressed |
  sed 's/"nombre"/"name"/g'`}"

  echo '    ## Saving current province localities...'
  # tr command needed to delete invisible character on curl
  # http://alvinalexander.com/blog/post/linux-unix/how-remove-non-printable-ascii-characters-file-unix
  text=$(echo ${text} | tr -cd '\11\12\15\40-\176')
  CURRENT_FILE=$(echo "by-province/${PROVINCES[${i}]}.json" | tr -d '[:space:]')
  echo ${text} > ${CURRENT_FILE}
  echo '    ## [DONE]'

  # Append current province localities to full json
  if [ -z "${full_json}" ]; then
    full_json="[${text}"
  else
    full_json="${full_json}, ${text}"
  fi
  echo "  ## [DONE]"
done

echo '## [DONE]'

echo '## Saving all localities per province...'
full_json="${full_json}]"

rm -f arg-localities.json
echo ${full_json} > arg-localities.json
echo '## [DONE]'
