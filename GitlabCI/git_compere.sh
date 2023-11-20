#!/bin/bash

#Запуск ./git_compere.sh <branch1> <branch2>
#./git_compere.sh master test_automation_part2


#from
BRANCH1="$1"
#into
BRANCH2="$2"
HOTFIX="$3"

LOCATION_COMPERE="./${BRANCH1}" 
FILE_PCK="${LOCATION_COMPERE}/patch.pck"

TEMP_FILE="temp_output.txt"

pars_by_extension () {
  echo "---------------------pars_by_extension ()-----------------------------------"
  for file in ${FILES[@]}; do

    xbase=${file##*/}
    extension="${file##*.}"
    filename=${xbase%.*}


    if [[ ${old_filenames[@]} =~ "${filename}" ]]   # если это новое имя файла то обрабатываем
    then
      echo "Такое имя  ${filename} уже было обработано."
    else

      IFS='/' read -ra array_parh <<< "$file"

      if [[ "${extension}" =~ (mp|plp|mcs) ]]     # plp, mp, mcs
      then
        result+="METH ${array_parh[-2]} ${filename}\n"
        echo $file
        old_filenames+=("${filename}")

      elif [[ "${extension}" =~ (vw|vp|vcs) ]]     # vw, vp, vcs
      then
        result+="CRIT ${array_parh[-2]} ${filename}\n"
        echo $file
        old_filenames+=("${filename}")

      elif [[ "${extension}" =~ (idx) ]]     # idx
      then
        result+="IDX ${array_parh[-2]} ${filename}\n"
        old_filenames+=("${filename}")
      fi
    fi
  done
}

prepare_TEMP_FILE (){
  $(git diff --output=${TEMP_FILE} "origin/$BRANCH2...origin/$BRANCH1" -- '*.tbp' )
  #Удаляем все строки которые не начинаются с +<tab>|-<tab>|+ |- |+++ b|--- b|--- /| 
  sed -i '/^+\t\|^-\t\|^+ \|^- \|^+++ b\|^--- b\|^--- \/d/!d' ${TEMP_FILE}
  sed -i 's/@name([^)]*)//g' ${TEMP_FILE}
  sed -i 's/[[:space:]]*//g' ${TEMP_FILE}
  sed -i 's/\[/ [/g' ${TEMP_FILE}
  sed -i 's/^+/+ /g' ${TEMP_FILE}
  sed -i 's/^-/- /g' ${TEMP_FILE}
  sed -i 's/^+ ++/+++ /g' ${TEMP_FILE}
  sed -i 's/^- --/--- /g' ${TEMP_FILE}
}

parsing_TEMP_FILE (){
  readarray tbps < ${TEMP_FILE}
  index=0

  while read line 
  do
    if [[ $line == ---[[:space:]]/dev* ]]
    then
      index=1
    fi

    if [[ $line == +++*  ]]
    then
      full_path="./${line:6}"
      xbase=${line##*/}
      filename=${xbase%.*}

      if [[ $index == 1 ]]
      then
        string_from_file=$(grep ^@name $full_path)
        string_from_file=$(sed "s/@name('*'//g" <<< "$string_from_file")
        string_from_file=$(sed "s/')//g" <<< "$string_from_file")
        result+="TYPE ${filename} '${string_from_file} \n"
        index=0
      fi
    fi

    if [[ $line == $'+ '* ]]
    then
      if [[ $index == 1 ]]
      then
        echo ${full_path}
        result+="TYPE \n"
      else
        IFS=' ' read -r -a array <<< "$line"
        result+="ATTR ${filename} ${array[1]}\n"
      fi
    fi
  done < ${TEMP_FILE}
}

create_patch_pck () {
  cat <<EOT > ${FILE_PCK}
VER2
REM Список элементов
REM CFT-Platform-IDE: AUTOMATION_RCCF

EOT
echo -e $result >> ${FILE_PCK}
}

create_platformproject (){
  cat <<EOT > ./UPDATE/platform.project
#$(date)
version=2
src-gen.path=src-gen
src.org.hierarchy=true
src.path=src
tbp.annotation.version2=true
vp.generate.base_class=false
vp.generate.qual=false
vw.validate.if_def_count=ERROR
vw.validate.if_def_type=ERROR
EOT
}

create_org_eclipse_core_resources_prefs () {
  cat <<EOT > ./UPDATE/.settings/org.eclipse.core.resources.prefs
eclipse.preferences.version=1
encoding/<project>=UTF-8
EOT
}

create_manifest_mf (){
  cat <<EOT > ./UPDATE/META-INFO/MANIFEST.MF
Manifest-Version: 1.0
CFT-Stream-Version: 1
CFT-Platform-IDE: 2.36.264
CFT-Deploy-Mode: EXACT
Datetime: $(date "+%d/%m/%Y %H:%M:%S")
EOT
}

create_structure () {
  mkdir -p ${LOCATION_COMPERE}
  mkdir -p UPDATE/{META-INFO,.settings}
  for file in ${FILES[@]}; do
    ext="${file##*.}"
    if [[ ! "${ext}" =~ (sh|yml|py) ]]     # sh, yml, py
    then
      cp --parents ./$file UPDATE/
    fi
  done
}

step_xml_import_elements1 () {
  IFS='' read -r -d '' XML_CONTENT_STEP1 << EOF
    <step info="$n. Импорт элементов модели (patch.zip, patch.pck)" name="import-storage" can-skip="false">
        <parameters>
          <parameter info="Проводить компиляцию операций и представлений" name="compilation" value="true" />
          <parameter info="Многопоточная компиляция операций" name="method-compilation-threads" value="false" />
          <parameter info="Проводить сбор статистики" name="check-stat" value="false" />
          <parameter info="Файл хранилища" name="storage-file" value="patch.zip" />
          <parameter info="Файл разметки" name="pck-file" value="patch.pck" />
          <parameter info="Режим отложенных действий" name="delayed-actions-mode" value="false" />
          <parameter info="Файл резервного хранилища" name="backup-file" value="Logs_$BRANCH1\01_backup_patch.zip" />
          <parameter info="Файл журнала монитора коммуникационного канала" name="oramon-file" value="Logs_$BRANCH1\01_oramon_patch.zip.log" />
          <parameter info="Файл логирования работы в безынтерфейсном режиме" name="log-file" value="Logs_$BRANCH1\01_pick_patch.zip.log" />
          <parameter info="Суммарное количество потоков" name="threads-count" value="1" />
        </parameters>
        <exceptions default-type="error">
          <exception info="Файл хранилища не доступен или не существует" name="storage-file-not-exists" type="error" />
          <exception info="Не удалось открыть файл хранилища" name="open-storage-file-failed" type="error" />
          <exception info="Невалидное хранилище. Работа с таким хранилищем невозможна." name="storage-file-is-invalid" type="error" />
          <exception info="Файл разметки не доступен или не существует" name="pck-file-not-exists" type="error" />
          <exception info="Не удалось прочитать файл разметки" name="open-pck-file-failed" type="error" />
          <exception info="Невалидный файл разметки. Работа с таким файлом невозможна." name="pck-file-is-invalid" type="error" />
          <exception info="Не удалось создать файл резервного хранилища" name="create-backup-file-failed" type="error" />
          <exception info="Ошибка проверки подписи" name="check-signature-failed" type="error" />
          <exception info="Не удалось создать файл журнала монитора" name="create-oramon-file-failed" type="error" />
          <exception info="Не удалось создать файл логирования" name="create-log-file-failed" type="error" />
          <exception info="Нет связи с Oracle (ORA-03114)" name="pick-exception" error-code="3114" type="error" />
          <exception info="Режим отложенных действий не поддерживается текущей версией ТЯ" name="pick-exception" error-code="3112" type="error" />
          <exception info="Произошла ошибка" name="pick-exception" type="error" />
        </exceptions>
      </step>
EOF
}

step_xml_import_elements2 () {
  IFS='' read -r -d '' XML_CONTENT_STEP2 << EOF
      <step info="$n. Выполнение SQL-скрипта (pattern_doc_import (1).sql)" name="run-sqlplus-file" can-skip="false">
        <parameters>
          <parameter info="Файл скрипта" name="sqlplus-file" value="SCRIPTS\!!!!!!!!!!pattern_doc_import (1).sql" />
          <parameter info="Параметры скрипта" name="script-parameters" value="!!!!!!!!!!!!!123.xml" />
          <parameter info="Файл журнала монитора коммуникационного канала" name="oramon-file" value="Logs_$BRANCH1\!!!!!!!!!!!!!!!02_oramon_script_[pattern_doc_import (1).sql].log" />
          <parameter info="Имя канала вывода" name="oramon-pipe" value="DEBUG$100" />
          <parameter info="Не учитывать ошибки при выполнении скрипта" name="skip-script-errors" value="false" />
          <parameter info="Файл результатов выполнения скрипта" name="spool-file" value="" />
        </parameters>
        <exceptions default-type="error">
          <exception info="Файл скрипта не существует" name="sqlplus-file-not-exists" type="error" />
          <exception info="Произошла ошибка на уровне операционной системы" name="sqlplus-os-exception" type="error" />
          <exception info="Не удалось запустить SQL*Plus" name="run-sqlplus-failed" type="error" />
          <exception info="Не удалось создать файл журнала монитора" name="create-oramon-file-failed" type="error" />
          <exception info="Произошла ошибка при запуске монитора" name="oramon-exception" type="error" />
          <exception info="Не удалось создать файл результатов выполнения" name="create-spool-file-failed" type="error" />
          <exception info="Нет связи с Oracle (ORA-03114)" name="sqlplus-exception" error-code="3114" type="error" />
          <exception info="Соединение потеряно (ORA-03135)" name="sqlplus-exception" error-code="3135" type="error" />
          <exception info="Невозможно выделить ХХХ байт разделяемой памяти (ORA-04031)" name="sqlplus-exception" error-code="4031" type="error" />
          <exception info="Были ошибки при работе скрипта для компиляции.&#xA;Запустите скрипт повторно, в случае повторения ошибки обратитесь в службу поддержки." name="sqlplus-exception" type="warning" error-code="20000" />
          <exception info="Произошла ошибка SQL*Plus" name="sqlplus-exception" type="error" />
        </exceptions>
      </step>
EOF
}

step_xml_import_elements3 () {
  IFS='' read -r -d '' XML_CONTENT_STEP3 << EOF
      <step info="$n. Выполнение операции ($filename_plp)" name="run-method" can-skip="false">
        <parameters>
          <parameter info="Короткое имя ТБП" name="class-id" value="$dir_plp" />
          <parameter info="Короткое имя операции" name="method-short-name" value="$filename_plp" />
          <parameter info="Файл журнала монитора коммуникационного канала" name="oramon-file" value="Logs_$BRANCH1\02_oramon_[$dir_plp]_[$filename_plp].log" />
        </parameters>
        <exceptions default-type="error">
          <exception info="Операция не существует" name="method-not-exists" type="error" />
          <exception info="Операция не групповая" name="method-not-static" type="error" />
          <exception info="Не удалось создать файл журнала монитора" name="create-oramon-file-failed" type="error" />
          <exception info="Произошла ошибка при запуске монитора" name="oramon-exception" type="error" />
          <exception info="При запуске тела операции произошла ошибка (SQL-exception)" name="sql-exception" type="error" />
        </exceptions>
      </step>
EOF
}

step_xml_import_elements4 () {
  IFS='' read -r -d '' XML_CONTENT_STEP4 << EOF
      <step info="$n. Копирование файлов на сервер" name="copy-files-to-server" can-skip="false">
        <parameters>
          <parameter info="Каталог-источник для копирования на сервер" name="source-dir" value="DATA" />
          <parameter info="Каталог-приёмник для копирования на сервер" name="target-dir" value="." />
          <parameter info="Файл логирования работы в безынтерфейсном режиме" name="log-file" value="Logs_$BRANCH1\01_oxch_copy_files_to_server.log" />
        </parameters>
        <exceptions default-type="error">
          <exception info="Каталог-источник не существует" name="source-dir-not-exists" type="error" />
          <exception info="Каталог-приёмник не существует" name="target-dir-not-exists" type="error" />
          <exception info="Не удалось создать файл логирования" name="create-log-file-failed" type="error" />
          <exception info="Не удалось загрузить файл на сервер" name="upload-file-failed" type="error" />
          <exception info="Произошла ошибка" name="oxch-exception" type="error" />
        </exceptions>
      </step>
EOF
}

create_xmlcontent (){
  echo "---------Prepare XML content---------"
  XML_CONTENT=""
  n=0
  for file in ${FILES[@]}; do

    echo $file
    xbase=${file##*/}
    echo $xbase

    if [[ $file =~ DATA ]]
    then
      n=$((n+1))
      step_xml_import_elements4
      XML_CONTENT+=$XML_CONTENT_STEP4
    fi

    if [[ $file =~ src ]]
    then
      if [ -z ${src_flag+x} ]
      then
        n=$((n+1))
        step_xml_import_elements1
        XML_CONTENT+=$XML_CONTENT_STEP1
        src_flag=True
      fi
    fi

    if [[ $file =~ SCRIPTS ]]
    then
      n=$((n+1))
      step_xml_import_elements2
      XML_CONTENT+=$XML_CONTENT_STEP2
    fi

    if [[ $file =~ "/CONV_" ]]
    then
      IFS='/' read -ra array_parh_plp <<< "$file"
      echo ${array_parh_plp[-2]}
      echo ${array_parh_plp[-1]}
      dir_plp="${array_parh_plp[-2]}"
      n=$((n+1))
      filename_plp=${xbase%.*}
      step_xml_import_elements3
      XML_CONTENT+=$XML_CONTENT_STEP3
    fi

  done
}

create_body_xml (){
  cat <<EOT > ${LOCATION_COMPERE}/${BRANCH1}.xml
<?xml version="1.0" encoding="utf-8"?>
<installations>
  <installation title="Установка ${BRANCH1}" welcome-text="Установка ${BRANCH1}" version-text="${BRANCH1}" log-file="Logs${BRANCH1}\CFTUpdate.log" >
    <constraints>
    </constraints>
    <steps>
    ${XML_CONTENT}
    </steps>
    <images>
    </images>
  </installation>
</installations>
EOT
}


clean () {
  rm ${TEMP_FILE}
  rm -r UPDATE
}

get_release_branch (){
  BRANCHS=($(git branch -r))
  BRANCHS_ARR=()
  for br in ${BRANCHS[@]}
  do
    if [[ "$br" == *"$BRANCH_NAME_PREFIX"* ]]
    then
      BN=${br##*/}
      BRANCHS_ARR+=(${BN#"$BRANCH_NAME_PREFIX"})
    fi
  done

  echo "--------------BRANCHS_ARR----------------------"
  IFS=$'\n' SORTED_BRANCHS=($(sort -n <<<"${BRANCHS_ARR[*]}")); unset IFS

  echo "Oбработанные ветки: ${SORTED_BRANCHS[*]}"

  for i in "${!SORTED_BRANCHS[@]}"
  do
    echo ${SORTED_BRANCHS[$i]} ${CI_COMMIT_REF_NAME#"$BRANCH_NAME_PREFIX"}
    if [[ ${SORTED_BRANCHS[$i]//,} == ${CI_COMMIT_REF_NAME#"$BRANCH_NAME_PREFIX"} ]]
    then
      I=$i
      echo ${SORTED_BRANCHS[$i]}
    fi
  done
  if [[ "$HOTFIX" == "hotfix" ]]
  then
    echo "---------Формируем hotfix---------"
  else
    echo "---------Формируем аккумулятивную поставку---------"
    BRANCH2="$BRANCH_NAME_PREFIX${SORTED_BRANCHS[$I-1]}"
  fi
}

create_mr () {
  curl --fail --output "/dev/null" --silent --show-error --write-out "HTTP response: ${http_code}\n\n" \
        --data "{\"title\": \"Automerge\", \"source_branch\": \"${CI_COMMIT_REF_NAME}\", \"target_branch\": \"${BRANCH2}\", \"force_remove_source_branch\": \"false\",\"squash\": \"true\"}" \
        --header "Content-Type: application/json" \
        --header "Private-Token: ${AUTOMERGE_PROJECT_TOKEN}" \
        --request POST \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests?"
}

upload_nexus (){
    if [[ "$HOTFIX" == "hotfix" ]]
    then
      echo "---------Загружаем на Nexus артифакта в ручном режиме---------"
    else
      echo "---------Загружаем на Nexus аккумулятивную поставку---------"
      curl -v -u ${NEXUS_USER}:${NEXUS_PASS} --upload-file ${BRANCH1}.zip ${NEXUS_SERVER}/repository/releases/ru/rencredit/${CI_PROJECT_NAME^^}/${BRANCH1#"$BRANCH_NAME_PREFIX"}/${BRANCH1}.zip
    fi
}

main (){
    get_release_branch
    echo "Сравнение релизные ветками origin/$BRANCH1 c origin/$BRANCH2"
    echo "git diff --name-only origin/${BRANCH2}...origin/${BRANCH1}"
    FILES=($(git diff --name-only "origin/$BRANCH2...origin/$BRANCH1"))
    echo "---------files from git diff---------"
    pars_by_extension
    prepare_TEMP_FILE
    parsing_TEMP_FILE
    create_structure
    create_patch_pck
    create_platformproject
    create_org_eclipse_core_resources_prefs
    create_manifest_mf
    (cd UPDATE; zip -r -q ../${LOCATION_COMPERE}/patch.zip * .* -x "../*")
    create_xmlcontent
    create_body_xml
    zip -r -q ${BRANCH1}.zip ${BRANCH1}
    [ -d "UPDATE/src" ] && upload_nexus

    clean
}

main
