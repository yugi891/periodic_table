#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table  -t --no-align -c"

ELEMENT_MESSAGE() {
  echo "The element with atomic number $1 is $2 ($3). It's a $4, with a mass of $5 amu. $2 has a melting point of $6 celsius and a boiling point of $7 celsius."
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # 输入参数是数字
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")
    if [[ -z $ELEMENT_INFO ]]
    then
      echo "I could not find that element in the database."
    else
      echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER ELEMENT_NAME ELEMENT_SYMBOL ELEMENT_TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        ELEMENT_MESSAGE $ATOMIC_NUMBER $ELEMENT_NAME $ELEMENT_SYMBOL $ELEMENT_TYPE $ATOMIC_MASS $MELTING_POINT $BOILING_POINT
      done
    fi
  # 输入参数不是数字
  else
    # 用symbol查找
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1'")
    if [[ -z $ELEMENT_INFO ]]
    then
      # 找不到,继续用name查找
      ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name='$1'")
      if [[ -z $ELEMENT_INFO ]]
      then
        # 找不到，输出找不到
        echo "I could not find that element in the database."
      else
        # 用name找到了，输出
        echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER ELEMENT_NAME ELEMENT_SYMBOL ELEMENT_TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
        do
          ELEMENT_MESSAGE $ATOMIC_NUMBER $ELEMENT_NAME $ELEMENT_SYMBOL $ELEMENT_TYPE $ATOMIC_MASS $MELTING_POINT $BOILING_POINT
        done
      fi
    else
      # 找到了，输出
      echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER ELEMENT_NAME ELEMENT_SYMBOL ELEMENT_TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        ELEMENT_MESSAGE $ATOMIC_NUMBER $ELEMENT_NAME $ELEMENT_SYMBOL $ELEMENT_TYPE $ATOMIC_MASS $MELTING_POINT $BOILING_POINT
      done
    fi
  fi
fi