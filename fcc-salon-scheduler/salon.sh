#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon Appointment Scheduler ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome! How can we help you?"
  AVAILABLE_SERVICES=$($PSQL "SELECT serivce_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "4) Exit\n"

  read SELECTED_SERVICE_ID

  case $SELECTED_SERVICE_ID in
    1) SERVICES_MENU "cut" ;;
    2) SERVICES_MENU "dye" ;;
    3) SERVICES_MENU "wash" ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid selection" ;;
  esac

}

SERVICES_MENU() {
    if [[ $1 ]]
    then
        SERVICE_NAME="$1"
    fi
    
    echo -e "\nPlease enter your phone number:"
    read PHONE_NUMBER

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER'")

    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nThere is no entry of you in our records. We will register you now. Please enter your name:"
        read CUSTOMER_NAME
        $($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$PHONE_NUMBER')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER'")


        echo -e "\nAt what time would you like to book the appointment?"
        read APPOINTMENT_TIME
        $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SELECTED_SERVICE_ID, '$APPOINTMENT_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME at $APPOINTMENT_TIME, $CUSTOMER_NAME"

    else
        # enter new appointment
        CUSTOMER_NAME=$($PSQL "SELECT customer_id FROM customers WHERE customer_id = '$CUSTOMER_ID'")
        echo -e "\nAt what time would you like to book the appointment?"
        read APPOINTMENT_TIME
        $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SELECTED_SERVICE_ID, '$APPOINTMENT_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME at $APPOINTMENT_TIME, $CUSTOMER_NAME"
    fi

}


EXIT() {
    echo -e "\nThank you for stopping by!"
}



